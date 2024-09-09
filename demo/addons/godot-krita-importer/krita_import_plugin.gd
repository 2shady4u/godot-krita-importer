# ############################################################################ #
# Copyright © 2022-2024 Piet Bronders <piet.bronders@gmail.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

@tool
extends EditorImportPlugin

var presets : Array[Dictionary] = [
	{
		"name": "ignore_invisible_layers", 
		"default_value": false
	},{
		"name": "texture_filter", 
		"default_value": CanvasItem.TEXTURE_FILTER_PARENT_NODE,
		"property_hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(range(0, CanvasItem.TEXTURE_FILTER_MAX))
	},{
		"name": "crop_to_visible", 
		"default_value": true
	},{
		"name": "center_sprites", 
		"default_value": true
	},{
		"name": "import_as_files", 
		"default_value": false
	}
]

func _get_import_options(path : String, preset : int) -> Array[Dictionary]:
	return presets

func _get_import_order() -> int:
	return 100

func _get_importer_name() -> String:
	return "godot-krita-importer"

func _get_option_visibility(path: String, option_name: StringName, options: Dictionary) -> bool:
	return true

func _get_preset_count() -> int:
	return 1

func _get_preset_name(preset : int) -> String:
	return "Default"

func _get_priority() -> float:
	return 1.0

func _get_recognized_extensions() -> PackedStringArray:
	return ["kra", "krz"]

func _get_resource_type() -> String:
	return "PackedScene"

func _get_save_extension() -> String:
	return "scn"

func _get_visible_name() -> String:
	return "Scene from Krita"

func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array, gen_files: Array) -> int:
	var importer = KraImporter.new()
	importer.verbosity_level = KraImporter.VerbosityLevel.QUIET

	var scene := PackedScene.new()
	var node := Node2D.new()
	node.name = source_file.get_file().get_basename()

	importer.load(source_file)

	var textures_dir: String =  source_file.get_basename() + "_kra_imported_files"
	for i in range(importer.layer_count - 1, -1, -1):
		var layer_data : Dictionary = importer.get_layer_data_at(i)

		match(layer_data.get("type", -1)):
			0:
				var sprite : Sprite2D = import_paint_layer(layer_data, options, textures_dir)
				if sprite != null:
					node.add_child(sprite)
			1:
				var child_node : Node2D = import_group_layer(importer, layer_data, options, textures_dir)
				if child_node != null:
					node.add_child(child_node)

	
	# All the children need to have the node as its owner!
	set_owner_recursively(node, node)

	scene.pack(node)
	var import_path := "%s.%s" % [save_path, _get_save_extension()]
	var error := ResourceSaver.save(scene, import_path)
	# The node needs to be freed to avoid memory leakage
	node.queue_free()
	
	var allowed_files := []
	for dep in ResourceLoader.get_dependencies(import_path):
		allowed_files.append(dep.get_slice("::", 2))

	# Purge all the obsolete '*.png'-files in the folder!
	purge_obsolete_textures_recursively(textures_dir, allowed_files)

	EditorInterface.get_base_control().get_tree().process_frame.connect(
		self._reimport_deferred.bind(gen_files)
	)

	return error

func _reimport_deferred(files: PackedStringArray):
	EditorInterface.get_base_control().get_tree().process_frame.disconnect(self._reimport_deferred)
	EditorInterface.get_resource_filesystem().scan()
	EditorInterface.get_resource_filesystem().scan_sources()

static func purge_obsolete_textures_recursively(save_dir: String, allowed_files: Array):
	if not DirAccess.dir_exists_absolute(save_dir):
		return

	for file in DirAccess.get_files_at(save_dir):
		if not ["png"].has(file.get_extension()):
			continue

		var file_path := save_dir.path_join(file)
		if allowed_files.has(file_path) :
			continue

		print("Removing " + file_path)
		DirAccess.remove_absolute(file_path)
		DirAccess.remove_absolute(file_path + ".import")
	for subdir in DirAccess.get_directories_at(save_dir):
		purge_obsolete_textures_recursively(save_dir.path_join(subdir), allowed_files)

	DirAccess.remove_absolute(save_dir + "/")

static func import_group_layer(importer: KraImporter, layer_data: Dictionary, options: Dictionary, textures_dir: String) -> Node2D:
	var node = Node2D.new()
	node.name = layer_data.get("name", node.name)
	node.position = layer_data.get("position", Vector2.ZERO)

	node.visible = layer_data.get("visible", true)
	if not node.visible and options.get("ignore_invisible_layers", false):
		return null
	node.modulate.a = layer_data.get("opacity", 255.0)/255.0

	var child_uuids : PackedStringArray = layer_data.get("child_uuids", PackedStringArray())
	# Needs to be in reverse order as to preserve layer ordering!
	for i in range(child_uuids.size() - 1, -1, -1):
		var uuid : String = child_uuids[i]
		var child_data : Dictionary = importer.get_layer_data_with_uuid(uuid)
		match(child_data.get("type", -1)):
			0:
				var sprite : Sprite2D = import_paint_layer(child_data, options, textures_dir.path_join(node.name))
				if sprite != null:
					sprite.position -= node.position
					node.add_child(sprite)
			1:
				var child_node : Node2D = import_group_layer(importer, child_data, options, textures_dir.path_join(node.name))
				if child_node != null:
					child_node.position -= node.position
					node.add_child(child_node)

	return node

static func import_paint_layer(layer_data: Dictionary, options: Dictionary, textures_dir: String) -> Node2D:
	var sprite = Sprite2D.new()
	sprite.name = layer_data.get("name", sprite.name)
	sprite.position = layer_data.get("position", Vector2.ZERO)

	sprite.visible = layer_data.get("visible", true)
	if not sprite.visible and options.get("ignore_invisible_layers", false):
		return null
	sprite.modulate.a = layer_data.get("opacity", 255.0)/255.0

	#create_from_data(width: int, height: int, use_mipmaps: bool, format: Format, data: PoolByteArray)
	var image = Image.create_from_data(layer_data.width, layer_data.height, false, layer_data.format, layer_data.data)

	if options.get("crop_to_visible", true):
		var visible_region = image.get_used_rect()
		image = image.get_region(visible_region)
		sprite.position += Vector2(visible_region.position)

	if options.get("center_sprites", true):
		sprite.position += Vector2(image.get_size())/2.0
		sprite.centered = true
	else:
		sprite.centered = false

	sprite.texture_filter = options.get("texture_filter", CanvasItem.TEXTURE_FILTER_PARENT_NODE)
	if options.get("import_as_files", false):
		# Make sure the path exists
		DirAccess.make_dir_recursive_absolute(textures_dir)
		var save_path: String = textures_dir.path_join("{name}.png".format({"name": sprite.name}))
		image.save_png(save_path)
		var texture = CompressedTexture2D.new()
		texture.take_over_path(save_path)
		sprite.texture = texture
	else:
		var texture = ImageTexture.create_from_image(image)
		sprite.texture = texture

	return sprite

static func enable_bit(mask, flag):
	return mask | flag

static func disable_bit(mask, flag):
	return mask & ~flag

static func set_owner_recursively(owner : Node2D, node : Node2D):
	for child in node.get_children():
		child.owner = owner

		set_owner_recursively(owner, child)
