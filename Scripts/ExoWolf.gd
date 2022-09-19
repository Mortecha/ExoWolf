extends KinematicBody

onready var gravity = -ProjectSettings.get_setting("physics/3d/default_gravity")
onready var rotor = $Chassis/Rotor
onready var camera: Camera = $CameraGimbal/Camera

const MAX_SPEED = 40
const MAX_ALTITUDE = 60
const TILT_COEF = 15 		# The max amount of tilt, Higher value less tilt  
const TILT_RESP = 4 		# The responsiveness of the tilting
const RAY_LENGTH = 2000

# Movement
var global_direction : Vector3 = Vector3()
var velocity: Vector3 = Vector3()

# Rotation
var space_state : PhysicsDirectSpaceState
var mouse_position : Vector2
var rayOrigin : Vector3
var rayEnd : Vector3
var intersection : Dictionary
var to_angle : float
var target : Vector3

func _ready():
	pass

func _physics_process(delta):
	rotate_towards_mouse(delta)
	
	global_direction.x = Input.get_axis("strafe_left", "strafe_right")
	global_direction.y = Input.get_axis("decrease_throttle", "increase_throttle")
	global_direction.z = Input.get_axis("move_forwards", "move_backwards")

	# Limit the input to a length of 1. length_squared is faster to check.
	if global_direction.length_squared() > 1: 
		global_direction /= global_direction.length()
	
	var local_direction = global_direction.rotated(Vector3.UP, rotation.y)
	velocity = local_direction * MAX_SPEED
	move_and_slide(velocity, Vector3.UP)
	
#	# Altitude limit check
	if transform.origin.y > MAX_ALTITUDE:
		velocity.y = 0
		transform.origin.y = MAX_ALTITUDE
	
	# Tilt based on movement
	rotation.x = lerp(rotation.x, global_direction.z / TILT_COEF, TILT_RESP)
	rotation.z = lerp(rotation.z, -global_direction.x / TILT_COEF, TILT_RESP)

func rotate_towards_mouse(delta):
	space_state = get_world().direct_space_state
	mouse_position = get_viewport().get_mouse_position()
	rayOrigin = camera.project_ray_origin(mouse_position)
	rayEnd = rayOrigin + camera.project_ray_normal(mouse_position) * RAY_LENGTH
	#parameters = PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd, 1)
	intersection = space_state.intersect_ray(rayOrigin, rayEnd, [],  1)
	if(not intersection.empty()):
		look_at(intersection.position, Vector3.UP)
		rotation.x = 0
		rotation.z = 0
