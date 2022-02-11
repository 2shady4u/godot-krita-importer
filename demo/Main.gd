extends Node2D

const KraImporter = preload("res://addons/godot-krita-importer/bin/libkra_importer.gdns")

func _ready():
	var importer := KraImporter.new()

	importer.load("whatever")
