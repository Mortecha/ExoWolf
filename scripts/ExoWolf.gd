extends KinematicBody

onready var gravity = -ProjectSettings.get_setting("physics/3d/default_gravity")
onready var rotor = $Chassis/Rotor
var camera: Camera

const MAX_SPEED = 20
const MAX_ALTITUDE = 60
const TILT_COEF = 15 		# The max amount of tilt, Higher value less tilt  
const TILT_RESP = 4 		# The responsiveness of the tilting
const RAY_LENGTH = 2000

# Movement
var global_direction : Vector3 = Vector3()
var velocity: Vector3 = Vector3()

# Rotation


func _ready():
	camera = get_viewport().get_camera()

func _physics_process(delta):
	
	camera.get_parent().transform.origin = transform.origin
	
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
	var space_state = get_world().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_position)
	var ray_end = ray_origin + camera.project_ray_origin(mouse_position) * RAY_LENGTH
	var intersection = space_state.intersect_ray(ray_origin, ray_end)
	if not intersection.empty():
		var pos = intersection.position
		look_at(Vector3(pos.x, transform.origin.y, pos.z), Vector3(0,1,0))
	
