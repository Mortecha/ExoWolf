extends CharacterBody3D

@onready var gravity = -ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var rotor = $Chassis/Rotor

const MAX_SPEED = 40
const MAX_ALTITUDE = 60
const ACC = 2
const DEC = .5
const TILT_COEF = 4 		# The max amount of tilt, Higher value less tilt  
const TILT_RESP = 4 		# The responsiveness of the tilting
const ROT_SPD = 4 			# Speed of rotation to point at mouse
const RAY_LENGTH = 2000

@export var camera : Camera3D

# Movement
var input_vector : Vector3 = Vector3()
var acceleration : float

# Rotation
var space_state : PhysicsDirectSpaceState3D
var mouse_position : Vector2
var rayOrigin : Vector3
var rayEnd : Vector3
var parameters : PhysicsRayQueryParameters3D
var intersection : Dictionary
var to_angle : float
var target : Vector3

func _ready():
	pass

func _physics_process(delta):
	rotate_towards_mouse(delta)
	
	input_vector.x = Input.get_axis(&"strafe_left", &"strafe_right")
	input_vector.y = Input.get_axis(&"decrease_throttle", &"increase_throttle")
	input_vector.z = Input.get_axis(&"move_forwards", &"move_backwards")

	# Limit the input to a length of 1. length_squared is faster to check.
	if input_vector.length_squared() > 1: input_vector /= input_vector.length()
	acceleration = ACC if input_vector.dot(velocity) > 0 else DEC

	velocity.y = input_vector.y * MAX_SPEED
	
	#var global_direction = Vector3(input_vector.x,0,input_vector.z)
	var local_direction = input_vector.rotated(Vector3(0,1,0), rotation.y)
	velocity = local_direction * MAX_SPEED
	move_and_slide()
	# Zeroing x and z rotations before translation prevent undesired movement downwards at odd angles
#	var current_rotation = rotation
#	rotation = Vector3(0, rotation.y, 0)
#	translate(input_vector)
#	rotation = current_rotation
	
#	# Altitude limit check
	if transform.origin.y > MAX_ALTITUDE:
		velocity.y = 0
		transform.origin.y = MAX_ALTITUDE
	
	# Tilt based on movement
#	rotation.x = lerp_angle(rotation.x, input_vector.z / TILT_COEF, TILT_RESP * delta)
#	rotation.z = lerp_angle(rotation.z, -input_vector.x / TILT_COEF, TILT_RESP * delta)

func rotate_towards_mouse(delta):
	space_state = get_world_3d().direct_space_state
	mouse_position = get_viewport().get_mouse_position()
	rayOrigin = camera.project_ray_origin(mouse_position)
	rayEnd = rayOrigin + camera.project_ray_normal(mouse_position) * RAY_LENGTH
	parameters = PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd, 1)
	intersection = space_state.intersect_ray(parameters)
	if(not intersection.is_empty()):
		look_at(intersection.position, Vector3.UP)
		rotation.x = 0
		rotation.z = 0
