# ############################################################################ #
# Copyright © 2022 Piet Bronders <piet.bronders@gmail.com>
# Licensed under the MIT License.
# See LICENSE in the project root for license information.
# ############################################################################ #

tool
extends EditorPlugin

var import_plugin = null

func get_name() -> String:
	return "Godot Krita Importer"

func _enter_tree():
	import_plugin = preload("krita_import_plugin.gd").new()
	add_import_plugin(import_plugin)

func _exit_tree():
	remove_import_plugin(import_plugin)
	import_plugin = null
