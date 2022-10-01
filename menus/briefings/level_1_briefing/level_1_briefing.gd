extends CanvasLayer

export(String, FILE) var main_menu
export(String, FILE) var level

func _ready():
	pass

func _on_main_menu_pressed():
	get_tree().change_scene(main_menu)

func _on_start_mission_pressed():
	get_tree().change_scene(level)
