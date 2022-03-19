# ############################################################################ #
# Copyright © 2022 Piet Bronders <piet.bronders@gmail.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends EditorImportPlugin

enum VerbosityLevel {
	QUIET,
	NORMAL,
	VERBOSE,
	VERY_VERBOSE
}

const presets := [
	{"name": "ignore_invisible_layers", "default_value": false},
	{"name": "flags/filter", "default_value": true},
]

const KraImporter = preload("res://addons/godot-krita-importer/bin/libkra_importer.gdns")

func get_import_options(preset : int) -> Array:
	return presets

func get_import_order() -> int:
	return 100

func get_importer_name() -> String:
	return "godot-krita-importer"

func get_option_visibility(option : String, options : Dictionary) -> bool:
	return true

func get_preset_count() -> int:
	return 1

func get_preset_name(preset : int) -> String:
	return "Default"

func get_priority() -> float:
	return 1.0

func get_recognized_extensions() -> Array:
	return ["kra", "krz"]

func get_resource_type() -> String:
	return "PackedScene"

func get_save_extension() -> String:
	return "scn"

func get_visible_name() -> String:
	return "Scene from Krita"

func import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array, gen_files: Array) -> int:
	var importer = KraImporter.new()
	importer.verbosity_level = VerbosityLevel.QUIET

	var scene := PackedScene.new()
	var node := Node2D.new()
	node.name = source_file.get_file().get_basename()

	importer.load(source_file)

	for i in range(importer.layer_count - 1, -1, -1):
		var layer_data : Dictionary = importer.get_layer_data_at(i)

		match(layer_data.get("type", -1)):
			0:
				var sprite : Sprite = import_paint_layer(layer_data, options)
				if sprite != null:
					node.add_child(sprite)
			1:
				var child_node : Node2D = import_group_layer(importer, layer_data, options)
				if child_node != null:
					node.add_child(child_node)

	# All the children need to have the node as its owner!
	set_owner_recursively(node, node)

	scene.pack(node)
	var error := ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], scene)
	# The node needs to be freed to avoid memory leakage
	node.queue_free()
	return error

static func import_group_layer(importer : KraImporter, layer_data : Dictionary, options: Dictionary) -> Node2D:
	var node = Node2D.new()
	node.name = layer_data.get("name", node.name)
	node.position = layer_data.get("position", Vector2.ZERO)

	node.visible = layer_data.get("visible", true)
	if not node.visible and options.get("ignore_invisible_layers", false):
		return null
	node.modulate.a = layer_data.get("opacity", 255.0)/255.0

	var child_uuids : PoolStringArray = layer_data.get("child_uuids", PoolStringArray())
	# Needs to be in reverse order as to preserve layer ordering!
	for i in range(child_uuids.size() - 1, -1, -1):
		var uuid : String = child_uuids[i]
		var child_data : Dictionary = importer.get_layer_data_with_uuid(uuid)
		match(child_data.get("type", -1)):
			0:
				var sprite : Sprite = import_paint_layer(child_data, options)
				if sprite != null:
					sprite.position -= node.position
					node.add_child(sprite)
			1:
				var child_node : Node2D = import_group_layer(importer, child_data, options)
				if child_node != null:
					child_node.position -= node.position
					node.add_child(child_node)

	return node

static func import_paint_layer(layer_data : Dictionary, options: Dictionary) -> Node2D:
	var sprite = Sprite.new()
	sprite.name = layer_data.get("name", sprite.name)
	sprite.position = layer_data.get("position", Vector2.ZERO)
	sprite.centered = false

	sprite.visible = layer_data.get("visible", true)
	if not sprite.visible and options.get("ignore_invisible_layers", false):
		return null
	sprite.modulate.a = layer_data.get("opacity", 255.0)/255.0

	var image = Image.new()
	#create_from_data(width: int, height: int, use_mipmaps: bool, format: Format, data: PoolByteArray)
	image.create_from_data(layer_data.width, layer_data.height, false, layer_data.format, layer_data.data)

	var texture = ImageTexture.new()
	texture.create_from_image(image)

	# Disable/enable the filter option which is positioned at the second bit position
	if options.get("flags/filter", true):
		texture.flags = enable_bit(texture.flags, Texture.FLAG_FILTER)
	else:
		texture.flags = disable_bit(texture.flags, Texture.FLAG_FILTER)

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
