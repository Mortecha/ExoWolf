extends Spatial

const WORLD_SIZE_X : int = 512
const WORLD_SIZE_Y : int = 512

const CAMERA_MIN_X : int = -211
const CAMERA_MAX_X : int = 211
const CAMERA_MIN_Z : int = -213
const CAMERA_MAX_Z : int = 208

var ray_origin : Vector3  = Vector3()
var ray_target : Vector3  = Vector3()
var ray_length : int  = 2000
var space_state : PhysicsDirectSpaceState
var mouse_position : Vector2
var intersection : Dictionary
var look_target : Vector3 = Vector3()

onready var player = $ExoWolf as KinematicBody
onready var camera = $CameraRig/CameraGimbal/Camera as Camera

func _ready():
	OS.window_fullscreen = true

func _physics_process(delta):
	cam_follow_player()
	player_mouse_look()

func cam_follow_player():
	$CameraRig.transform.origin = player.transform.origin
	$CameraRig.transform.origin.x = clamp($CameraRig.transform.origin.x, CAMERA_MIN_X, CAMERA_MAX_X)
	$CameraRig.transform.origin.z = clamp($CameraRig.transform.origin.z, CAMERA_MIN_Z, CAMERA_MAX_Z)

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
		player.look_at(look_target, Vector3.UP)
