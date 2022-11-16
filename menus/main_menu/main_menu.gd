extends CanvasLayer

@export var level # (String, FILE)

@onready var settings_menu = $SettingsMenu
@onready var start_btn = $MainMenu/MarginContainer/VBoxContainer/StartGameBtn

func _on_start_pressed():
	get_tree().change_scene_to_file(level)

func _on_settings_pressed():
	settings_menu.show()

func _on_quit_pressed():
	get_tree().quit()
