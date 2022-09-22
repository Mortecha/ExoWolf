extends Spatial

const WORLD_SIZE_X : int = 512
const WORLD_SIZE_Y : int = 512

const CAMERA_MIN_X : int = -211
const CAMERA_MAX_X : int = 211
const CAMERA_MIN_Z : int = -213
const CAMERA_MAX_Z : int = 208

export var cam_speed : float = 1

var ray_origin : Vector3  = Vector3()
var ray_target : Vector3  = Vector3()
var ray_length : int  = 2000
var space_state : PhysicsDirectSpaceState
var mouse_position : Vector2
var intersection : Dictionary
var look_target : Vector3 = Vector3()

onready var player = $ExoWolf as KinematicBody
onready var camera = $CameraRig/CameraGimbal/Camera as Camera

var time_delta

func _ready():
	pass
	#OS.window_fullscreen = true
	
func _physics_process(delta):
	time_delta = delta
	cam_movement()
	player_mouse_look()

func cam_movement():
	mouse_player_interpolation()
	$CameraRig.transform.origin.x = clamp($CameraRig.transform.origin.x, CAMERA_MIN_X, CAMERA_MAX_X)
	$CameraRig.transform.origin.y = 0.0
	$CameraRig.transform.origin.z = clamp($CameraRig.transform.origin.z, CAMERA_MIN_Z, CAMERA_MAX_Z)
	

func mouse_player_interpolation():
	#$CameraRig.transform.origin = player.transform.origin
	var target_position : Vector3 = (look_target + player.transform.origin) / 2
	$CameraRig.transform.origin = $CameraRig.transform.origin.linear_interpolate(target_position, cam_speed * time_delta)

func player_mouse_look():
	space_state = get_world().direct_space_state
	mouse_position = get_viewport().get_mouse_position()
	ray_origin = camera.project_ray_origin(mouse_position)
	ray_target = ray_origin + camera.project_ray_normal(mouse_position) * ray_length
	intersection = space_state.intersect_ray(ray_origin, ray_target)
	if not intersection.empty():
		look_target.x = intersection.position.x
		look_target.y = player.transform.origin.y
		look_target.z = intersection.position.z
		var diff = look_target - player.transform.origin
		if diff.x > 0.1 or diff.x < 0.1 and diff.z > 0.1 or diff.z < 0.1:
			player.look_at(look_target, Vector3.UP)
