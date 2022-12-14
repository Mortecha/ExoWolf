extends Control

var is_paused = false :
	get:
		return is_paused # TODOConverter40 Non existent get function 
	set(mod_value):
		mod_value  # TODOConverter40 Copy here content of set_paused

@onready var settings_menu = $SettingsMenu

func _ready():
	hide()


func set_paused(value):
	is_paused = value
	get_tree().paused = value
	visible = is_paused
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if is_paused == true else Input.MOUSE_MODE_CAPTURED)
	
func _on_ResumeBtn_pressed():
	self.is_paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_SettingsBtn_pressed():
	settings_menu.popup_centered()


func _on_QuitBtn_pressed():
	get_tree().quit()



func _on_start_pressed():
	pass # Replace with function body.
