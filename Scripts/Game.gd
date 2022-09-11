extends Spatial

var ray_origin = Vector3()
var ray_target = Vector3()
var ray_length = 2000
var mouse_position
var intersection

onready var player = $ExoWolf as KinematicBody
#onready var navmap = $Navigation

func _ready():
	pass
	#OS.window_fullscreen = true

func _physics_process(delta):
	var space_state = get_world().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	ray_origin = $CameraPivot/Camera.project_ray_origin(mouse_position)
	ray_target = ray_origin + $CameraPivot/Camera.project_ray_normal(mouse_position) * ray_length
	var intersection = space_state.intersect_ray(ray_origin, ray_target)
	if not intersection.empty():
		var pos = intersection.position
		player.look_at(Vector3(pos.x, pos.y, pos.z), Vector3.UP)
	
#	if is_instance_valid(player):
#		mouse_position = get_viewport().get_mouse_position()	
#		ray_origin = $CameraPivot/Camera.project_ray_origin(mouse_position)
#		ray_target = ray_origin + $CameraPivot/Camera.project_ray_normal(mouse_position) * ray_length
#		intersection = get_world().direct_space_state.intersect_ray(ray_origin, ray_target, [], 8)	
#		if not intersection.empty():
#			var target_vector = Vector3(intersection.position.x, player.translation.y, intersection.position.z)
#			player.look_at(target_vector, Vector3.UP)

