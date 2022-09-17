extends Control

func _ready():
	$VBoxContainer/StartButton.grab_focus()

func _process(delta):
	pass

func _on_StartButton_pressed():
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_OptionsButton_pressed():
	var options = load("res://Menus/Options.tscn").instance()
	get_tree().current_scene.add_child(options)

func _on_QuitButton_pressed():
	get_tree().quit()
