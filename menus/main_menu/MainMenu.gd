extends Control

func _ready():
	$VBoxContainer/StartButton.grab_focus()

func _on_Start_Button_pressed():
	get_tree().change_scene("res://menus/briefings/level_1_briefing.tscn")

func _on_Options_Button_pressed():
	var options = load("res://menus/options_menu/options_menu.tscn").instance()
	get_tree().current_scene.add_child(options)

func _on_Quit_Button_pressed():
	get_tree().quit()
