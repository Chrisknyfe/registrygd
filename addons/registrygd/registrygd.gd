@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
		"RegisteredObject",
		"Resource",
		preload("res://addons/registrygd/registered_object.gd"),
		null
	)
	add_custom_type(
		"Registry",
		"Refcounted",
		preload("res://addons/registrygd/registry.gd"),
		null
	)


func _exit_tree():
	remove_custom_type("Registry")
	remove_custom_type("RegisteredObject")
