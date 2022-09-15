extends CharacterBody3D

@onready var gravity = -ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var rotor = $Chassis/Rotor

const MAX_SPEED = 40
const MAX_ALTITUDE = 60
const ACCELERATION = 2
const DECELERATION = 4
const TILT_ANGLE = 5
const SMOOTH_SPEED = 4

# Movement
var dir : Vector3 = Vector3()
var acceleration : float
var vel : Vector3

func _ready():
	pass

func _physics_process(delta):
	# Apply gravity.
	#velocity.y += delta * gravity
	
	dir.x = Input.get_axis(&"strafe_left", &"strafe_right")
	dir.y = Input.get_axis(&"decrease_throttle", &"increase_throttle")
	dir.z = Input.get_axis(&"move_forwards", &"move_backwards")

	# Limit the input to a length of 1. length_squared is faster to check.
	if dir.length_squared() > 1:
		dir /= dir.length()
		
	# Using only the horizontal velocity, interpolate towards the input.
	vel = velocity
 
	if dir.dot(vel) > 0:
		acceleration = ACCELERATION
	else:
		acceleration = DECELERATION

	vel = vel.lerp(dir * MAX_SPEED, acceleration * delta)

	# Assign vel's values back to velocity, and then move.
	velocity.x = vel.x
	velocity.z = vel.z

	if transform.origin.y <= MAX_ALTITUDE:
		velocity.y = vel.y
	else:
		velocity.y = 0
		transform.origin.y = MAX_ALTITUDE
	
	var rot : Vector3 = rotation
	var new_rot : Vector3 = Vector3()
	new_rot.x = dir.z * TILT_ANGLE
	new_rot.z = -dir.x * TILT_ANGLE
	rotation = lerp(Vector3.ZERO, new_rot, delta * SMOOTH_SPEED)
	
	# Use this to figure out how to rotate y
	#rotation.y = lerp_angle(rotation.y, atan2(-dir.x, -dir.z), delta * SMOOTH_SPEED)
	
	# TODO: This information should be set to the CharacterBody properties instead of arguments: , Vector3.UP
	# TODO: Rename velocity to linear_velocity in the rest of the script.
	move_and_slide()

