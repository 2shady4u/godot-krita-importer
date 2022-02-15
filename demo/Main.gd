extends Node2D

const KraImporter = preload("res://addons/godot-krita-importer/bin/libkra_importer.gdns")

func _ready():
	var importer := KraImporter.new()

	importer.load("res://KraExample.Kra")

	print(importer.layer_count)

	for i in range(importer.layer_count - 1, -1, -1):
		var layer_data = importer.get_layer_data(i)

		var sprite = Sprite.new()
		sprite.name = layer_data.get("name", sprite.name)
		sprite.position = layer_data.get("position", Vector2.ZERO)
		sprite.centered = false

		sprite.visible = layer_data.get("visible", true)
		sprite.modulate.a = layer_data.get("opacity", 255.0)/255.0

		var image = Image.new()
		#print(layer_data)
		#create_from_data(width: int, height: int, use_mipmaps: bool, format: Format, data: PoolByteArray)
		image.create_from_data(layer_data.width, layer_data.height, false, Image.FORMAT_RGBA8, layer_data.data)

		var texture = ImageTexture.new()
		texture.create_from_image(image)

		sprite.texture = texture

		add_child(sprite)
