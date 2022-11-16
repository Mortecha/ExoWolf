# follow_camera.gd
# Configures the follow camera system
#
# This code is part of Thalassikopter. Copyright (C) 2021-2022 waimus
# https://gitlab.com/waimus/thalassikopter
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node3D

# Target configurations
@export var target_path: NodePath : NodePath
@onready var spring_arm : SpringArm3D = get_node("SpringArm3D")
var target_node : Node3D
var camera_speed : float = 15.0
var pilot_camera_toggle : bool = false
var follow_camera : Camera3D
var pilot_camera : Camera3D

# Freelook configurations
var freelook_rotation : Vector3 = Vector3()
var freelook_return_time : float = 10.0

# Pilot camera configurations
var pilot_min_fov : float = 45.0
var pilot_max_fov : float = 82.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.freelook = false
	
	if target_path:
		target_node = get_node(target_path)
		follow_camera = get_node("SpringArm3D/Camera3D")
		pilot_camera = get_node("PilotOffset/Camera3D")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	camera_freelook(delta)
	camera_follow_control(delta)
	camera_pilot_fov(delta)


func _input(event) -> void:
	# Toggle active camera
	if event.is_action_pressed("cl_toggle_camera"):
		self.pilot_camera_toggle = !self.pilot_camera_toggle
		
		follow_camera.set_current(!self.pilot_camera_toggle)
		pilot_camera.set_current(self.pilot_camera_toggle)
		camera_toggle()
	
	if event is InputEventMouseButton:
		# Modifiable spring arm length, zoom out & zoom in
		if event.button_index == 5 and spring_arm.spring_length < 10:
			spring_arm.spring_length += 0.25
		if event.button_index == 4 and spring_arm.spring_length > 3:
			spring_arm.spring_length -= 0.25


func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		self.freelook_rotation.x += event.relative.y * -1 / (Globals.mouse_smoothing * 1)
		self.freelook_rotation.y += event.relative.x * -1 / (Globals.mouse_smoothing * 1)
		self.freelook_rotation.z = 0


func camera_freelook(delta : float) -> void:
	if !target_node:
		return
	
	var dir : Vector3 = target_node.get_rotation()
	
	# Freelooking implementation
	if Globals.freelook:
		self.rotation = self.freelook_rotation 
		self.rotation.z = 0
		
		# Pilot camera freelook
		if pilot_camera_toggle:
			pilot_camera.rotation_degrees.x = rad_to_deg(self.freelook_rotation.x)
			pilot_camera.rotation_degrees.y = rad_to_deg(pilot_camera.rotation.y + Globals.mouse_offset.x * -2)
			pilot_camera.rotation_degrees.z = 0
	else:
		self.rotation.x = lerp_angle(self.rotation.x, dir.x, self.freelook_return_time * delta)
		self.rotation.y = lerp_angle(self.rotation.y, dir.y, self.freelook_return_time * delta)
		self.rotation.z = 0
		
		# Pilot camera freelook
		pilot_camera.rotation_degrees.x = lerp(pilot_camera.rotation_degrees.x, pilot_camera.get_parent().get_rotation_degrees().x + -13, self.freelook_return_time * delta)
		pilot_camera.rotation_degrees.y = lerp(pilot_camera.rotation_degrees.y, pilot_camera.get_parent().get_rotation_degrees().y + 180, self.freelook_return_time * delta)
		pilot_camera.rotation_degrees.z = 0
		
		self.freelook_rotation = Vector3(0, self.rotation.y, 0)
	
	# Limit rotation
	self.rotation_degrees.x = clamp(self.rotation_degrees.x, -40, 100)
	pilot_camera.rotation_degrees.y = clamp(pilot_camera.rotation_degrees.y, 135, 240)
	pilot_camera.rotation_degrees.x = clamp(pilot_camera.rotation_degrees.x, -55, 70)


func camera_follow_control(delta : float) -> void:
	if !target_node:
		return
	
	var target_position : Transform3D = target_node.global_transform
	self.global_transform.origin = lerp(self.global_transform.origin, target_position.origin, self.camera_speed * delta)
	
	# Don't follow target's rotation
	if !Globals.freelook:
		self.rotation.x = 0


func camera_toggle() -> void:
	if pilot_camera_toggle:
		# Attach to body so camera will follow body's rotation animation
		$PilotOffset.remove_child(pilot_camera)
		target_node.get_node("dauphin/Body/PilotOffset").add_child(pilot_camera)
		
		# Offset
#		pilot_camera.set_position(Vector3(0.15, 0.7, 0.6))
		pilot_camera.set_rotation_degrees(Vector3(0, 180, 0))
	else:
		if pilot_camera.get_parent() == target_node.get_node("dauphin/Body/PilotOffset"):
			target_node.get_node("dauphin/Body/PilotOffset").remove_child(pilot_camera)
			$PilotOffset.add_child(pilot_camera)


func camera_pilot_fov(delta : float) -> void:
	if Input.is_action_pressed("cl_pilot_zoom"):
		pilot_camera.set_fov(lerp(pilot_camera.get_fov(), pilot_min_fov, 10 * delta))
	else:
		pilot_camera.set_fov(lerp(pilot_camera.get_fov(), pilot_max_fov, 10 * delta))

