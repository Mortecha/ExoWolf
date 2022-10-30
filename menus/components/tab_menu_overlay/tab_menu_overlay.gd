extends Control

export(String, FILE) var main_menu
var is_paused = false setget set_paused

onready var settings_menu = $SettingsMenu

func _ready():
	hide()

func set_paused(value):
	is_paused = value
	get_tree().paused = value
	visible = is_paused
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if is_paused == true else Input.MOUSE_MODE_CAPTURED)
	
func _on_resume_pressed():
	self.is_paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene(main_menu)

func _on_SettingsBtn_pressed():
	settings_menu.popup_centered()

func _on_quit_pressed():
	get_tree().quit()

