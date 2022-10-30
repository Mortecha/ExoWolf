extends Node

class_name Stats

export var max_hp = 1
onready var current_hp = max_hp

signal death_signal

func _ready():
	pass

func take_hit(damage):
	current_hp -= damage
	if current_hp <= 0:
		die()
		
func die():
	emit_signal("death_signal")
