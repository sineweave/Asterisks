@tool
extends EditorPlugin

var ui : Control = null

func _enter_tree():
	ui = load("res://addons/asterisks/main.tscn").instantiate()
	ui.name = "Asterisks"
	ui.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ui.size_flags_vertical = Control.SIZE_EXPAND_FILL
	EditorInterface.get_editor_main_screen().add_child(ui)
	ui.hide()

func _exit_tree() -> void:
	ui.queue_free()

func _make_visible(visible: bool) -> void:
	ui.visible = visible

func _get_plugin_name() -> String:
	return "Asterisks"

func _has_main_screen() -> bool:
	return true
