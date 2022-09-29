extends Control

export(String, FILE) var level

func _ready():
	pass

func _on_Button_pressed():
	get_tree().change_scene(level)
