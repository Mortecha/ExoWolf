extends CanvasLayer

@export var level # (String, FILE)

@onready var settings_menu = $SettingsMenu
@onready var start_btn = $MainMenu/MarginContainer/VBoxContainer/StartGameBtn

func _ready():
	start_btn.grab_focus()

func _on_StartGameBtn_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene_to_file(level)


func _on_SettingsBtn_pressed():
	settings_menu.popup_centered()


func _on_ExitBtn_pressed():
	get_tree().quit()
