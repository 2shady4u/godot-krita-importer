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

	importer.load(source_file)

	return 0
