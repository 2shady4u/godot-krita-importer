extends Node2D

const KraImporter = preload("res://addons/godot-krita-importer/bin/libkra_importer.gdns")

func _ready():
	var importer := KraImporter.new()
	importer.load("res://addons/godot-krita-importer/examples/example.kra")

	var options := {
		"ignore_invisible_layers": false,
		"flags/filter": false
	}

	# We can't instance this class, but we can still access the static methods!
	var import_plugin = preload("res://addons/godot-krita-importer/krita_import_plugin.gd")

	for i in range(importer.layer_count - 1, -1, -1):
		var layer_data : Dictionary = importer.get_layer_data_at(i)

		match(layer_data.get("type", -1)):
			0:
				var sprite : Sprite = import_plugin.import_paint_layer(layer_data, options)
				if sprite != null:
					add_child(sprite)
			1:
				var child_node : Node2D = import_plugin.import_group_layer(importer, layer_data, options)
				if child_node != null:
					add_child(child_node)

	# All the children need to have the node as its owner!
	import_plugin.set_owner_recursively(self, self)
