@tool
extends EditorPlugin


func _enter_tree():
	add_child(load("res://main.tscn").instance())
	pass


func _exit_tree():
	# Clean-up of the plugin goes here.
	pass
