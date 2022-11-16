extends CanvasLayer

@export var main_menu # (String, FILE)
@export var level # (String, FILE)

func _ready():
	pass

func _on_main_menu_pressed():
	get_tree().change_scene_to_file(main_menu)

func _on_start_mission_pressed():
	get_tree().change_scene_to_file(level)
