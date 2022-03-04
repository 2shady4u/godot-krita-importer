extends Node2D

const KraImporter = preload("res://addons/godot-krita-importer/bin/libkra_importer.gdns")

func _ready():
	var importer := KraImporter.new()
	var options := {
		"ignore_invisible_layers": false,
		"flags/filter": false
	}

	importer.load("res://addons/godot-krita-importer/examples/example.kra")

	for i in range(importer.layer_count - 1, -1, -1):
		var layer_data : Dictionary = importer.get_layer_data_at(i)

		match(layer_data.get("type", -1)):
			0:
				var sprite : Sprite = import_paint_layer(layer_data, options)
				if sprite != null:
					add_child(sprite)
			1:
				var child_node : Node2D = import_group_layer(importer, layer_data, options)
				if child_node != null:
					add_child(child_node)

	# All the children need to have the node as its owner!
	set_owner_recursively(self, self)

func import_group_layer(importer : KraImporter, layer_data : Dictionary, options: Dictionary) -> Node2D:
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

func import_paint_layer(layer_data : Dictionary, options: Dictionary) -> Node2D:
	var sprite = Sprite.new()
	sprite.name = layer_data.get("name", sprite.name)
	sprite.position = layer_data.get("position", Vector2.ZERO)
	sprite.centered = false

	sprite.visible = layer_data.get("visible", true)
	if not sprite.visible and options.get("ignore_invisible_layers", false):
		return null
	sprite.modulate.a = layer_data.get("opacity", 255.0)/255.0

	var image = Image.new()
	#print(layer_data)
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

func enable_bit(mask, flag):
	return mask | flag

func disable_bit(mask, flag):
	return mask & ~flag

func set_owner_recursively(owner : Node2D, node : Node2D):
	for child in node.get_children():
		child.owner = owner

		set_owner_recursively(owner, child)
