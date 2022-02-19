# ############################################################################ #
# Copyright © 2022 Piet Bronders <piet.bronders@gmail.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends EditorImportPlugin

const KraImporter = preload("res://addons/godot-krita-importer/bin/libkra_importer.gdns")

func get_import_options(preset : int) -> Array:
	return [{"name": "my_option", "default_value": false}]

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
	var scene := PackedScene.new()
	var node := Node2D.new()
	node.name = source_file.get_file().get_basename()

	importer.load(source_file)

	print(importer.layer_count)

	for i in range(importer.layer_count - 1, -1, -1):
		var layer_data : Dictionary = importer.get_layer_data_at(i)

		match(layer_data.get("type", -1)):
			0:
				var sprite : Sprite = import_paint_layer(layer_data)
				node.add_child(sprite)
			1:
				var child_node : Node2D = import_group_layer(importer, layer_data)
				node.add_child(child_node)

	# All the children need to have the node as its owner!
	set_owner_recursively(node, node)

	scene.pack(node)
	return ResourceSaver.save("%s.%s" % [save_path, get_save_extension()], scene)

func import_group_layer(importer : KraImporter, layer_data : Dictionary) -> Node2D:
	var node = Node2D.new()
	node.name = layer_data.get("name", node.name)
	node.position = layer_data.get("position", Vector2.ZERO)

	node.visible = layer_data.get("visible", true)
	node.modulate.a = layer_data.get("opacity", 255.0)/255.0

	var child_uuids : PoolStringArray = layer_data.get("child_uuids", PoolStringArray())
	for uuid in child_uuids:
		print(uuid)
		var child_data : Dictionary = importer.get_layer_data_with_uuid(uuid)
		match(child_data.get("type", -1)):
			0:
				var sprite : Sprite = import_paint_layer(child_data)
				sprite.position -= node.position
				node.add_child(sprite)
			1:
				var child_node : Node2D = import_group_layer(importer, child_data)
				child_node.position -= node.position
				node.add_child(child_node)

	return node

func import_paint_layer(layer_data : Dictionary) -> Node2D:
	var sprite = Sprite.new()
	sprite.name = layer_data.get("name", sprite.name)
	sprite.position = layer_data.get("position", Vector2.ZERO)
	sprite.centered = false

	sprite.visible = layer_data.get("visible", true)
	sprite.modulate.a = layer_data.get("opacity", 255.0)/255.0

	var image = Image.new()
	#print(layer_data)
	#create_from_data(width: int, height: int, use_mipmaps: bool, format: Format, data: PoolByteArray)
	image.create_from_data(layer_data.width, layer_data.height, false, layer_data.format, layer_data.data)

	var texture = ImageTexture.new()
	texture.create_from_image(image)

	sprite.texture = texture

	return sprite

func set_owner_recursively(owner : Node2D, node : Node2D):
	for child in node.get_children():
		child.owner = owner

		set_owner_recursively(owner, child)
