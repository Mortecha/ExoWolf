# globals.gd
# Stores global game configuration and utilities
#
# This code is part of Thalassikopter. Copyright (C) 2021-2022 waimus
# https://gitlab.com/waimus/thalassikopter
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node


# UI Scaling configurations
var ui_scaling : float = 1

# Mouse Configuration
var mouse_sensitivity : float = 75
var mouse_smoothing : float = 600
var mouse_offset : Vector3
var mouse_receiving : bool = false
var mouse_motion_count : int
var mouse_motion_last_count : int

# Freelook configurations
var freelook : bool = false


func _ready() -> void:
	pass
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_EXPAND, Vector2(1280, 720), ui_scaling)
#
#	update_mouse_sensitivity(mouse_sensitivity)


func _process(delta) -> void:
	mouse_move_check()


# Global input event listener
func _input(event) -> void:
	if event.is_action_pressed("cl_freelook"):
		Globals.freelook = true
	if event.is_action_released("cl_freelook"):
		Globals.freelook = false
		
	elif event.is_action_pressed("game_fullscreen"):
		OS.set_window_fullscreen(!OS.window_fullscreen)
		
	elif event.is_action_pressed("game_reload"):
		var e = get_tree().reload_current_scene()
		if e == OK:
			print("scene reloaded, Code: %s" % e)
		else:
			print("error reloading scene, Code: %s" % e)


func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		var menu_exists : bool = is_instance_valid(get_tree().get_current_scene().get_node("InGameMenu"))
		if menu_exists:
			print("Cannot quit game: in-game menu exits (%s)" %  get_tree().get_current_scene().get_node("InGameMenu").get_path())
		else:
			print("Quitting . . .")
			get_tree().quit()
	
	if event is InputEventMouseMotion: 
		mouse_motion_count += 1

		var x : float = event.relative.x / (mouse_smoothing * 2)
		var z : float = event.relative.y / (mouse_smoothing * 2)
		mouse_offset = Vector3(x, 0, z)


func mouse_move_check() -> void:
	if mouse_motion_last_count != mouse_motion_count:
		mouse_receiving = true
		mouse_motion_last_count = mouse_motion_count
	else:
#		mouse_receiving = false
		mouse_offset = Vector3.ZERO


func update_mouse_sensitivity(value: float) -> void:
	mouse_smoothing = invert_by_max(value, 100) * 10


func invert_by_max(var value : float, var max_value : float) -> float:
	return max_value - value
