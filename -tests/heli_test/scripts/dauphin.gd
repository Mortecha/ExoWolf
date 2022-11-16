# dauphin.gd
# Configures this Dauphin helicopter model
# This node needs to be attached to MetaHelicopter
#
# This code is part of Thalassikopter. Copyright (C) 2021-2022 waimus
# https://gitlab.com/waimus/thalassikopter
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends Node3D


# Properties
@export var meta_helicopter_path: NodePath : NodePath
var meta_helicopter : Node3D

# Animation properties
@onready var rotor_animation : AnimationPlayer = get_node("AnimRotor")
@onready var back_rotor_animation : AnimationPlayer = get_node("AnimationPlayer")
@onready var turning_animation_tree : AnimationTree = get_node("AnimationTree")

# Gear properties
@onready var front_gear : Node3D = get_node("Body/FrontWheelHandler")
@onready var back_gear : Node3D = get_node("Body/BackWheelHandler")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if meta_helicopter_path:
		meta_helicopter = get_node(meta_helicopter_path)
	
	if !turning_animation_tree.active:
		turning_animation_tree.set_active(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	if meta_helicopter:
		configure_animation()
		interpolate_to_parent()
		configure_gear()


func interpolate_to_parent() -> void:
	self.global_transform = self.global_transform.interpolate_with(meta_helicopter.get_global_transform(), 0.3)
	
	if !meta_helicopter.is_grounded:
		# Set mesh as top level to detach from jittering rigidbody
		self.set_as_top_level(true)
	else:
		self.set_as_top_level(false)


func configure_animation() -> void:
	# Rotor animations based checked engine power
	rotor_animation.play("dauphinRotorAction", -1, (meta_helicopter.engine_power / 100) * 30)
	back_rotor_animation.play("BackRotorAction", -1, (meta_helicopter.engine_power / 100) * 5)
	
	# Turning animation based checked mouse position
	if !meta_helicopter.is_grounded:
		var x : float = (meta_helicopter.helper_rot.position.x / 8) + 1 * 0.5
		var z : float = (meta_helicopter.helper_rot.position.z / 5) + 1 * 0.5
		
		var x_weight : float = lerp(turning_animation_tree.get("parameters/horizontal/blend_amount"), x, 0.3)
		var z_weight : float = lerp(turning_animation_tree.get("parameters/vertical/blend_amount"), z, 0.3)
		
		turning_animation_tree.set("parameters/horizontal/blend_amount", x_weight)
		turning_animation_tree.set("parameters/vertical/blend_amount", z_weight)
	else:
		var x_weight : float = lerp(turning_animation_tree.get("parameters/horizontal/blend_amount"), 0.5, 0.2)
		var z_weight : float = lerp(turning_animation_tree.get("parameters/vertical/blend_amount"), 0.5, 0.2)
		turning_animation_tree.set("parameters/horizontal/blend_amount", x_weight)
		turning_animation_tree.set("parameters/vertical/blend_amount", z_weight)


func configure_gear() -> void:
	front_gear.set_visible(meta_helicopter.gear_toggle)
	back_gear.set_visible(meta_helicopter.gear_toggle)
