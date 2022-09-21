extends KinematicBody

onready var gravity = -ProjectSettings.get_setting("physics/3d/default_gravity")
onready var rotor = $Chassis/Rotor

var camera: Camera
var ray_origin = Vector3()
var ray_target = Vector3()
var ray_length = 2000
var mouse_position
var intersection

const MAX_SPEED = 10
const MAX_ALTITUDE = 12
const TILT_COEF = 15 		# The max amount of tilt, Higher value less tilt  
const TILT_RESP = 4 		# The responsiveness of the tilting
const RAY_LENGTH = 2000

# Movement
var global_direction : Vector3 = Vector3()
var velocity: Vector3 = Vector3()

# Rotation


func _ready():
	camera = $CameraRig/CameraGimbal/Camera

func _physics_process(delta):
	
	rotate_towards_mouse(delta)
	
	global_direction.x = Input.get_axis("player_left", "player_right")
	global_direction.y = Input.get_axis("player_decrease_throttle", "player_increase_throttle")
	global_direction.z = Input.get_axis("player_forwards", "player_backwards")

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

func rotate_towards_mouse(delta):
	pass
#	var space_state = get_world().direct_space_state
#	var mouse_position = get_viewport().get_mouse_position()
#	ray_origin = $CameraRig/CameraGimbal/Camera.project_ray_origin(mouse_position)
#	ray_target = ray_origin + $CameraRig/CameraGimbal/Camera.project_ray_normal(mouse_position) * ray_length
#	var intersection = space_state.intersect_ray(ray_origin, ray_target)
#	if not intersection.empty():
#		var pos = intersection.position
#		look_at(Vector3(pos.x, pos.y, pos.z), Vector3.UP)
	
