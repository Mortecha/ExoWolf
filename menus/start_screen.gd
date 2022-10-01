extends CanvasLayer

export(String, FILE) var level

onready var settings_menu = $SettingsMenu
onready var start_btn = $MainMenu/MarginContainer/VBoxContainer/StartGameBtn

func _on_start_pressed():
	get_tree().change_scene(level)

func _on_settings_pressed():
	settings_menu.popup_centered()

func _on_quit_pressed():
	get_tree().quit()
