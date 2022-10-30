extends Node

var health = 100
var is_dead = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func take_hit(damage):
	health -= damage
	if(health <= 0):
		is_dead = true
