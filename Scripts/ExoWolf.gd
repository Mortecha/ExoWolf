extends CharacterBody3D

@onready var gravity = -ProjectSettings.get_setting("physics/3d/default_gravity")

const MAX_SPEED = 40
const ACCELERATION = 2
const DECELERATION = 4

# Movement
var movement_dir : Vector3 = Vector3()
var acceleration
var target

# Rotor
@onready var rotor = $Chassis/Rotor

func _ready():
	pass

func _physics_process(delta):
	# Apply gravity.
	velocity.y += delta * gravity

	movement_dir.x = Input.get_axis(&"rotate_left", &"rotate_right")
	movement_dir.z = Input.get_axis(&"move_forwards", &"move_backwards")
#
	# Limit the input to a length of 1. length_squared is faster to check.
	if movement_dir.length_squared() > 1:
		movement_dir /= movement_dir.length()
		
	# Using only the horizontal velocity, interpolate towards the input.
	var hvel = velocity
	hvel.y = 0

	target = movement_dir * MAX_SPEED
	if movement_dir.dot(hvel) > 0:
		acceleration = ACCELERATION
	else:
		acceleration = DECELERATION

	hvel = hvel.lerp(target, acceleration * delta)

	# Assign hvel's values back to velocity, and then move.
	velocity.x = hvel.x
	velocity.z = hvel.z
	# TODO: This information should be set to the CharacterBody properties instead of arguments: , Vector3.UP
	# TODO: Rename velocity to linear_velocity in the rest of the script.
	move_and_slide()
	handle_throttle()	
	
func handle_throttle():
	pass
