extends Spatial

var ray_origin : Vector3 = Vector3()
var ray_target : Vector3 = Vector3()
var ray_length : int = 2000
var mouse_position : Vector2
var space_state : PhysicsDirectSpaceState
var intersection : Dictionary
var pos : Vector3

onready var player = $ExoWolf as KinematicBody

func _ready():
	pass
	#OS.window_fullscreen = true

func _physics_process(delta):
	space_state = get_world().direct_space_state
	mouse_position = get_viewport().get_mouse_position()
	ray_origin = $CameraPivot/Camera.project_ray_origin(mouse_position)
	ray_target = ray_origin + $CameraPivot/Camera.project_ray_normal(mouse_position) * ray_length
	intersection = space_state.intersect_ray(ray_origin, ray_target)
	if not intersection.empty():
		pos = intersection.position
		player.look_at(Vector3(pos.x, player.transform.origin.y, pos.z), Vector3.UP)

