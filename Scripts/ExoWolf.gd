extends CharacterBody3D

@export var gravity : Vector3 = Vector3.DOWN * 9.8
#var velocity : Vector3 = Vector3.ZERO

const MAX_SPEED = 20
const JUMP_SPEED = 5
const ACCELERATION = 4
const DECELERATION = 8

# Movement
var movement_dir : Vector3 = Vector3()
var movement_speed : float = 0.0
@export var max_movement_speed : float = -50.0
@export var min_movement_speed : float = 30.0
var movement_acc_coef : float = 0.75
var move_damp_coef : float = 0.25
var acceleration
var target

# Strafing
var strafe_speed : float = 0.0
var max_strafe_speed : float = 25.0

# Throttle
@export var max_altitude : int = 50
var throttle = 1

# Rotor
@onready var rotor = $Chassis/Rotor

func _ready():
	pass

func _physics_process(delta):
	velocity += delta * gravity
	
	var dir = Vector3()
	dir.x = Input.get_axis(&"rotate_left", &"rotate_right")
	dir.z = Input.get_axis(&"move_forwards", &"move_backwards")
#
	# Limit the input to a length of 1. length_squared is faster to check.
	if dir.length_squared() > 1:
		dir /= dir.length()
		
	# Apply gravity.
	#velocity.y += delta * gravity

	# Using only the horizontal velocity, interpolate towards the input.
	var hvel = velocity
	hvel.y = 0

	target = dir * MAX_SPEED
	if dir.dot(hvel) > 0:
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
#	if(!is_on_floor()):
#		handle_movement()	
#		#handle_rotation()
#
#	handle_throttle()	
#
	move_and_slide()
	
func handle_movement():
	var velocity_y : float = velocity.y
	velocity = Vector3.ZERO
	
	if Input.is_action_pressed("move_forwards"):
		move_forwards()				
	elif Input.is_action_pressed("move_backwards"):
		move_backwards()	
	else:
		dampen_movement()
	handle_stafing()
	velocity += transform.basis.z * movement_speed
	velocity += transform.basis.x * strafe_speed
	velocity.y = velocity_y

func move_forwards():
	if(movement_speed > max_movement_speed):
		movement_speed -= movement_acc_coef
	else:
		movement_speed = max_movement_speed

func move_backwards():
	if(movement_speed < min_movement_speed):
		movement_speed += movement_acc_coef
	else:
		movement_speed = min_movement_speed

func dampen_movement():
	if(movement_speed > 1):
		movement_speed -= move_damp_coef
	elif(movement_speed < -1):
		movement_speed += move_damp_coef
	else:
		movement_speed = 0

func handle_throttle():
	if Input.is_action_pressed("increase_throttle"):
		throttle = 1
		rotor._set_rotor_to_boost()
	elif Input.is_action_pressed("decrease_throttle"):
		throttle = -1
		rotor._set_rotor_to_landed()
	else:
		throttle = 0
		rotor._set_rotor_to_flight()
	velocity += transform.basis.y * throttle
	
	if(transform.origin.y > max_altitude):
		transform.origin.y = max_altitude		
	
func handle_stafing():
	if Input.is_action_pressed("rotate_left"):	
		strafe_left()	
	elif Input.is_action_pressed("rotate_right"):	
		strafe_right()
	else:
		dampen_strafing()

func strafe_left():
	if(strafe_speed > max_movement_speed):
		strafe_speed -= movement_acc_coef
	else:
		strafe_speed = max_movement_speed

func strafe_right():
	if(strafe_speed < min_movement_speed):
		strafe_speed += movement_acc_coef
	else:
		strafe_speed = min_movement_speed

func dampen_strafing():
	if(strafe_speed > 1):
		strafe_speed -= move_damp_coef
	elif(strafe_speed < -1):
		strafe_speed += move_damp_coef
	else:
		strafe_speed = 0
