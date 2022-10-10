# helicopter_hud.gd
# Controls HUD related to the helicopter control
#
# This code is part of Thalassikopter. Copyright (C) 2021-2022 waimus
# https://gitlab.com/waimus/thalassikopter
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Control


# Data from helicopter
export(NodePath) var meta_helicopter : NodePath
var helicopter : Spatial

# Data from  helper
#export(NodePath) var helicopter_helper : NodePath
var helpers : Spatial

# UI nodes
onready var velocity_panel : Panel = get_node("VelocityGraph/Panel")
onready var lift_progress : Panel = get_node("LiftForceProgress/Panel")
onready var power_progress : Panel = get_node("PowerProgress/Panel")
onready var angular_progress : Panel = get_node("AngularProgress/Panel")

onready var label_speed : Label = get_node("Panel/VBoxContainer/SPD/LabelSpeed")
onready var label_altitude : Label = get_node("Panel/VBoxContainer/ALT/LabelAltitude")
onready var label_fps : Label = get_node("LabelFPS")
onready var compass : HBoxContainer = get_node("Compass/Panel/Clip/HBoxContainer")
onready var compass_degree : Label = get_node("Compass/Panel/DegreeContainer/degree")

onready var message_container : VBoxContainer = get_node("Panel/MessageBoxContainer")

#var message_popup : PackedScene = preload("res://heli_test/ui/nodes/MessagePanel.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if meta_helicopter:
		helicopter = get_node(meta_helicopter)
		helpers = helicopter.get_node("HelicopterHelper")
		
		# Insert signals here
		var signals : Array = [
				helicopter.connect("ui_power_changed", self, "_on_power_changed"),
				helicopter.connect("ui_angular_changed", self, "_on_angular_changed"),
				helicopter.connect("ui_update_compass", self, "_on_update_compass"),
				helicopter.connect("ui_messaging", self, "_on_message_received"),
				helpers.connect("ui_direction_moved", self, "_on_direction_helper_moved"),
				helpers.connect("ui_lifts_weight", self, "_on_lift_weight_changed"),
		]
		
		print("Signal count: %s" % signals.size())


func _process(delta) -> void:
	var velocity_z : int = int(abs(helicopter.transform.basis.xform_inv(helicopter.linear_velocity).z) * 3.6)
	label_speed.set_text("%s km/h" % velocity_z)
	
	if helicopter.ground_visible:
		var height_dist : float = helicopter.ground_distance
		label_altitude.set_text("%s m (AGL)" % int(height_dist))
	else:
		var height_dist : float = helicopter.sea_distance
		label_altitude.set_text("%s m (ASL)" % int(height_dist))
	
	label_fps.set_text("FPS: %s" % int(Engine.get_frames_per_second()))


func _on_message_received(var level : String, var msg : String) -> void:
	print("[%s] %s" % [level, msg])
	
#	var popup : Label = message_popup.instance()
#	popup.message = "[%s] %s" %  [level, msg]
#
#	match level:
#		"INFO":
#			popup.colour = Color.springgreen
#			popup.display_time = 2
#		"WARN":
#			popup.colour = Color.yellow
#			popup.display_time = 4
#		"ERROR":
#			popup.colour = Color.orangered
#			popup.display_time = 5
#		_:
#			popup.colour = Color.white
#			popup.display_time = 1
#
#	message_container.add_child(popup)


func _on_direction_helper_moved(var dir : Vector3) -> void:
	# Helper: (0, 0) is center, min=-1, max=1 for both X and Y
	# UI: (25, 25) is center, min=0, max=50 for both X and Y
	# Solution: (x + 1, y + 1) * 25 to align helper to UI
	velocity_panel.set_position(Vector2(dir.x + 1, dir.z + 1) * 25, true)


func _on_lift_weight_changed(var weight : float) -> void:
	# Advanced: set the margin to make it expand instead of just sliding
	if weight > 0:
		lift_progress.set_margin(MARGIN_BOTTOM, 2)
		lift_progress.set_margin(MARGIN_TOP, (weight * -70) - 5)
	elif weight < 0:
		lift_progress.set_margin(MARGIN_TOP, -2)
		lift_progress.set_margin(MARGIN_BOTTOM, (weight * -70) + 5)
	else:
		lift_progress.set_margin(MARGIN_TOP, lerp(lift_progress.margin_top, 0, 0.25))
		lift_progress.set_margin(MARGIN_BOTTOM, lerp(lift_progress.margin_bottom, 0, 0.25))


func _on_power_changed(var power : float) -> void:
	power_progress.set_margin(MARGIN_TOP, (power / 100) * -150)


func _on_angular_changed(var velocity : float) -> void:
	if velocity > 0.1:
		angular_progress.set_margin(MARGIN_LEFT, -3)
		angular_progress.set_margin(MARGIN_RIGHT, velocity * 100 / 2)
	elif velocity < -0.1:
		angular_progress.set_margin(MARGIN_RIGHT, 3)
		angular_progress.set_margin(MARGIN_LEFT, velocity * 100 / 2)
	
	angular_progress.set_margin(MARGIN_RIGHT, clamp(angular_progress.margin_right, 0, 100))
	angular_progress.set_margin(MARGIN_LEFT, clamp(angular_progress.margin_left, -100, 0))


func _on_update_compass(var angle : float) -> void:
	# Angle gets multiplied by 2 so it can counts half direction between two directions (i.e. NE/NW/SW/SE)
	# Angle * 2 - offset
	compass.set_position(Vector2(angle * 2 - 360, 20), true)
	
	# Compas degree config
	var degree : int = int(angle)
	if degree < 1:
		degree = angle + 360
	compass_degree.set_text("%s" % Globals.invert_by_max(degree, 360))

