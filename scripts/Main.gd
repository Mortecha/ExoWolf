extends Node3D

const WORLD_SIZE_X : int = 512
const WORLD_SIZE_Y : int = 512

const CAMERA_MIN_X : int = -211
const CAMERA_MAX_X : int = 211
const CAMERA_MIN_Z : int = -213
const CAMERA_MAX_Z : int = 208

@export var cam_speed : float = 1
@export var num_enemies = 4

var ray_origin : Vector3  = Vector3()
var ray_target : Vector3  = Vector3()
var ray_length : int  = 2000
var space_state : PhysicsDirectSpaceState3D
var mouse_position : Vector2
var intersection : Dictionary
var look_target : Vector3 = Vector3()



@onready var player = $ExoWolf as CharacterBody3D
@onready var camera = $CameraRig/CameraGimbal/Camera3D as Camera3D

@onready var compass : HBoxContainer = $InGameMenu/Compass/Panel/Clip/HBoxContainer
@onready var compass_degree : Label = $InGameMenu/Compass/Panel/DegreeContainer/degree

@onready var mission_complete_overlay = $GUI/MissionCompleteOverlay

var time_delta

# Minimap
@export var minimap_zoom = .25
@onready var minimap_grid = $InGameMenu/MiniMap/MiniMap/Grid
@onready var minimap_player_marker = $InGameMenu/MiniMap/MiniMap/Grid/PlayerMarker
@onready var minimap_enemy_marker = $InGameMenu/MiniMap/MiniMap/Grid/EnemyMarker
@onready var minimap_icons = {"enemy" : minimap_enemy_marker}
var minimap_edge_offset = 10
var minimap_grid_scale # Size of the world down to the size of the map
var minimap_markers = {}

func _ready():
	if true:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
else:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# Minimap
	minimap_player_marker.position = minimap_grid.size / 2
	minimap_grid_scale = minimap_grid.size / (minimap_grid.get_parent().get_viewport_rect().size * minimap_zoom)
	
	var enemies = $Enemies.get_children()#.get_nodes_in_group(minimap_objects)
	for enemy in enemies:
		var new_enemy_marker = minimap_enemy_marker.duplicate()
		minimap_grid.add_child(new_enemy_marker)
		new_enemy_marker.show()
		minimap_markers[enemy] = new_enemy_marker
	
func _physics_process(delta):
	
	if(num_enemies == 0):
		mission_complete_overlay.is_paused = true
		$GUI/MissionCompleteOverlay/AudioStreamPlayer.play()
	
	time_delta = delta
	cam_movement()
	player_mouse_look()
	update_compass(player.rotation_degrees.y)
	update_minimap(player.rotation_degrees.y)
	
	if Input.is_action_pressed("fire_minigun"):
		player.fire_minigun()

func cam_movement():
	mouse_player_interpolation()
	$CameraRig.transform.origin.x = clamp($CameraRig.transform.origin.x, CAMERA_MIN_X, CAMERA_MAX_X)
	$CameraRig.transform.origin.y = 0.0
	$CameraRig.transform.origin.z = clamp($CameraRig.transform.origin.z, CAMERA_MIN_Z, CAMERA_MAX_Z)
	
func mouse_player_interpolation():
	#$CameraRig.transform.origin = player.transform.origin
	var target_position : Vector3 = (look_target + player.transform.origin) / 2
	$CameraRig.transform.origin = $CameraRig.transform.origin.lerp(target_position, cam_speed * time_delta)

func player_mouse_look():
	space_state = get_world_3d().direct_space_state
	mouse_position = get_viewport().get_mouse_position()
	ray_origin = camera.project_ray_origin(mouse_position)
	ray_target = ray_origin + camera.project_ray_normal(mouse_position) * ray_length
	intersection = space_state.intersect_ray(ray_origin, ray_target)
	if not intersection.is_empty():
		look_target.x = intersection.position.x
		look_target.y = player.transform.origin.y
		look_target.z = intersection.position.z
		var diff = look_target - player.transform.origin
		if diff.x > 0.1 or diff.x < 0.1 and diff.z > 0.1 or diff.z < 0.1:
			player.look_at(look_target, Vector3.UP)
			player.set_turret_target(intersection.position)
	
func update_compass(angle : float):
	# Angle gets multiplied by 2 so it can counts half direction between two directions (i.e. NE/NW/SW/SE)
	# Angle * 2 - offset
	compass.set_position(Vector2(angle * 2 - 360, 20), true)
	
	# Compas degree config
	var degree : int = int(angle)
	if degree < 1:
		degree = angle + 360
	compass_degree.set_text("%s" % Globals.invert_by_max(degree, 360))

func update_minimap(angle : float):
	minimap_player_marker.rotation = deg_to_rad(-angle)
	
	for marker in minimap_markers:
		if(is_instance_valid(marker)):
			var marker_pos = Vector2(marker.transform.origin.x, marker.transform.origin.z)
			var player_pos = Vector2(player.transform.origin.x, player.transform.origin.z)
			var marker_position = (marker_pos - player_pos) * minimap_grid_scale + minimap_grid.size / 2
			var dist_from_center = (minimap_grid.size / 2).distance_to(marker_position)
			var detection_range = 125
			if minimap_grid.get_rect().has_point(marker_position + minimap_grid.position) and dist_from_center < detection_range:
				#minimap_markers[marker].scale = Vector2(0.2, 0.2)
				if !minimap_markers[marker].visible:
					minimap_markers[marker].show()
			else:
				minimap_markers[marker].hide()

			marker_position.x = clamp(marker_position.x, minimap_edge_offset, minimap_grid.size.x - minimap_edge_offset)
			marker_position.y = clamp(marker_position.y, minimap_edge_offset, minimap_grid.size.y - minimap_edge_offset)
			minimap_markers[marker].position = marker_position

func clear_minimap():
	for marker in minimap_markers:
		minimap_markers.erase(marker)

func redraw_minimap():
	# Minimap
	var new_minimap_markers = {}
	var enemies = $Enemies.get_children()#.get_nodes_in_group(minimap_objects)
	for enemy in enemies:
		var new_enemy_marker = minimap_enemy_marker.duplicate()
		minimap_grid.add_child(new_enemy_marker)
		new_enemy_marker.show()
		new_minimap_markers[enemy] = new_enemy_marker
	
	minimap_markers = new_minimap_markers

func _on_Stats_death_signal():
	num_enemies -= 1
	print("death signal recieved")
	clear_minimap()
	redraw_minimap()
