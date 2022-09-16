extends CharacterBody3D

@onready var gravity = -ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var rotor = $Chassis/Rotor

const MAX_SPEED = 40
const MAX_ALTITUDE = 60
const ACC = 2
const DEC = 4
const TILT_COEF = 4 		# The max amount of tilt, Higher value less tilt  
const TILT_RESP = 4 		# The responsiveness of the tilting
const ROT_SPD = 4 			# Speed of rotation to point at mouse
const RAY_LENGTH = 2000

@export var camera : Camera3D

# Movement
var dir : Vector3 = Vector3()
var acceleration : float

# Rotation
var space_state : PhysicsDirectSpaceState3D
var mouse_position : Vector2
var rayOrigin : Vector3
var rayEnd : Vector3
var parameters : PhysicsRayQueryParameters3D
var intersection : Dictionary
var to_angle : float

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
	rotation.x = lerp_angle(rotation.x, dir.z / TILT_COEF, TILT_RESP * delta)
	rotation.z = lerp_angle(rotation.z, -dir.x / TILT_COEF, TILT_RESP * delta)
	
	# Use this to figure out how to rotate y
	#rotation.y = lerp_angle(rotation.y, atan2(-dir.x, -dir.z), TILT_RESP * delta)
	
	space_state = get_world_3d().direct_space_state
	mouse_position = get_viewport().get_mouse_position()
	rayOrigin = camera.project_ray_origin(mouse_position)
	rayEnd = rayOrigin + camera.project_ray_normal(mouse_position) * RAY_LENGTH
	parameters = PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd)
	intersection = space_state.intersect_ray(parameters)
	if not intersection.is_empty():
		to_angle = atan2(-intersection.position.x, -intersection.position.z)
		rotation.y = lerp_angle(rotation.y, to_angle, TILT_RESP * delta)

