extends Node2D

const KraImporter = preload("res://addons/godot-krita-importer/bin/libkra_importer.gdns")

func _ready():
	var importer := KraImporter.new()

	importer.load("res://KraExample.Kra")

	print(importer.layer_count)

	for i in range(0, importer.layer_count):
		var data = importer.get_layer_data(i)
		print(data.name)
