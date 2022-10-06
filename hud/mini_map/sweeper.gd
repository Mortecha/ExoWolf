extends Control

var rotation_speed = 0.15

func _process(delta):
	set_rotation(get_rotation() + rotation_speed)
