extends CharacterBody3D

@onready var gravity = -ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var rotor = $Chassis/Rotor

const MAX_SPEED = 40
const MAX_ALTITUDE = 60
const ACC = 2
const DEC = 4
const TILT_COEF = 4 # The max amount of tilt, Higher value less tilt  
const TILT_RESP = 4 # The responsiveness of the tilting

# Movement
var dir : Vector3 = Vector3()
var acceleration : float

func _ready():
	pass

func _physics_process(delta):	
	dir.x = Input.get_axis(&"strafe_left", &"strafe_right")
	dir.y = Input.get_axis(&"decrease_throttle", &"increase_throttle")
	dir.z = Input.get_axis(&"move_forwards", &"move_backwards")

	# Limit the input to a length of 1. length_squared is faster to check.
	if dir.length_squared() > 1: dir /= dir.length()
	acceleration = ACC if dir.dot(velocity) > 0 else DEC
	velocity = velocity.lerp(dir * MAX_SPEED, acceleration * delta)

	# Altitude limit check
	if transform.origin.y > MAX_ALTITUDE:
		velocity.y = 0
		transform.origin.y = MAX_ALTITUDE
		
	move_and_slide()
	
	# Tilt based on movement
	rotation.x = lerp_angle(rotation.x, dir.z / TILT_COEF, delta * TILT_RESP)
	rotation.z = lerp_angle(rotation.z, -dir.x / TILT_COEF, delta * TILT_RESP)
	
	# Use this to figure out how to rotate y
	#rotation.y = lerp_angle(rotation.y, atan2(-dir.x, -dir.z), delta * TILT_RESP)
	

