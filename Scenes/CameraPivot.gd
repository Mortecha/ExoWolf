extends Node3D

@onready var target = $"../ExoWolf"
@export var distance = 4.0
@export var height = 2.0

@export var interesting_camera : bool = false

func _ready():
	pass # Replace with function body.

func _process(_delta):
	if(interesting_camera):
		var target_position = target.global_transform.origin
		var pos = global_transform.origin
		var up = Vector3(0, 1, 0)
		
		var offset = pos - target_position
		offset = offset.normalized()*distance
		offset.y = height
		pos = target_position + offset
		
		look_at_from_position(pos, target_position, up)
		#look_at(target_position, up)
	else:
		transform.origin.x = target.transform.origin.x
		transform.origin.z = target.transform.origin.z
