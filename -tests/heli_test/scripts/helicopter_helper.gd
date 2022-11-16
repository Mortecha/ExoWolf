# helicopter_helper.gd
# controls visualization for input
# mesh may be disabled in final game, but the actual transform data is used by the meta_helicopter.gd
#
# This code is part of Thalassikopter. Copyright (C) 2021-2022 waimus
# https://gitlab.com/waimus/thalassikopter
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node3D

# Configurations
@export var meta_helicopter_path: NodePath : NodePath
var meta_helicopter : RigidBody3D

# Keyboard configurations
var keyboard_x : float = 0
var keyboard_z : float = 0
var keyboard_move_dir : Vector3
var keyboard_move_sensitivity : float = 0.7

# Signals for UI
signal ui_direction_moved(dir)
signal ui_lifts_weight(weight)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if meta_helicopter_path:
		meta_helicopter = get_node(meta_helicopter_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta) -> void:
	helper_vertical_velocity(delta)
	helper_rotation_keyboard(delta)
	helper_direction_move()


func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		# Emit signal to feed the UI info to show
		emit_signal("ui_direction_moved", $Pivot/DirectionHelper.position)


func helper_direction_move() -> void:
	if Globals.mouse_receiving:
		$Pivot/RotationHelper.position.x = clamp($Pivot/RotationHelper.position.x, -8, 8)
		$Pivot/RotationHelper.position.z = clamp($Pivot/RotationHelper.position.z, -5, 5)
	
	$Pivot/DirectionHelper.position = $Pivot/RotationHelper.position
	$Pivot/DirectionHelper.position.x = clamp($Pivot/DirectionHelper.position.x, -1, 1)
	$Pivot/DirectionHelper.position.z = clamp($Pivot/DirectionHelper.position.z, -1, 1)


# $RotationHelper keyboard input for cosmetic rotation
# Mixed with mouse input but under specified conditions
func helper_rotation_keyboard(delta : float) -> void:
	var inputs : Array = [
			Input.is_action_pressed("cl_cyclic_forward"), 
			Input.is_action_pressed("cl_cyclic_backward"), 
			Input.is_action_pressed("cl_cyclic_right"), 
			Input.is_action_pressed("cl_cyclic_left"),
	]
	var mouse_offset : Vector3 = Globals.mouse_offset
	self.keyboard_move_dir = $Pivot/RotationHelper.position
	
	if Globals.freelook or meta_helicopter.is_grounded:
		mouse_offset = Vector3.ZERO
	
	self.keyboard_z = (Input.get_action_strength("cl_cyclic_forward") * -self.keyboard_move_sensitivity) - (Input.get_action_strength("cl_cyclic_backward") * -self.keyboard_move_sensitivity)
	self.keyboard_x = (Input.get_action_strength("cl_cyclic_right") * self.keyboard_move_sensitivity) - (Input.get_action_strength("cl_cyclic_left") * self.keyboard_move_sensitivity)
	
	# If any input key pressed and mouse stopped
	if inputs.has(true) and !Globals.mouse_receiving:
		self.keyboard_move_dir.x = lerp(self.keyboard_move_dir.x, self.keyboard_x, delta)
		self.keyboard_move_dir.z = lerp(self.keyboard_move_dir.z, self.keyboard_z, delta)
		
		# Feed info to UI
		emit_signal("ui_direction_moved", $Pivot/DirectionHelper.position)
	# If no input key pressed
	if !inputs.has(true):
		# Reset direction
		self.keyboard_x = 0
		self.keyboard_z = 0
		# If movement is damped or helicopter is landed
		if meta_helicopter.force_damping or meta_helicopter.is_grounded:
			self.keyboard_move_dir.x = lerp(self.keyboard_move_dir.x, 0, delta)
			self.keyboard_move_dir.z = lerp(self.keyboard_move_dir.z, 0, delta)
			
			# Feed info to UI
			emit_signal("ui_direction_moved", $Pivot/DirectionHelper.position)
	
	# Use keyboard input when mouse isn't moved
	if Globals.mouse_receiving:
		$Pivot/RotationHelper.position += mouse_offset * 2
	else:
		$Pivot/RotationHelper.position = self.keyboard_move_dir
	#printt(inputs.has(true), meta_helicopter.linear_damp, keyboard_x, keyboard_z)


# $VerticalVelocity helper
func helper_vertical_velocity(delta : float) -> void:
	var helper_yvel : float = $Pivot/VerticalVelocity.position.y
	if Input.is_action_pressed("cl_collective_raise"):
		helper_yvel = lerp(helper_yvel, 1, 5 * delta)
		emit_signal("ui_lifts_weight", $Pivot/VerticalVelocity.position.y)
	elif Input.is_action_pressed("cl_collective_lower"):
		helper_yvel = lerp(helper_yvel, -1, 5 * delta)
		emit_signal("ui_lifts_weight", $Pivot/VerticalVelocity.position.y)
	else:
		helper_yvel = lerp(helper_yvel, 0, 5 * delta)
		emit_signal("ui_lifts_weight", 0)
	$Pivot/VerticalVelocity.position.y = helper_yvel

