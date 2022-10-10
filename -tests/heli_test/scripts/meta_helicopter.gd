# meta_helicopter.gd
# Configures the basic helicopter system
#
# This code is part of Thalassikopter. Copyright (C) 2021-2022 waimus
# https://gitlab.com/waimus/thalassikopter
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

extends RigidBody


# Configurations
export var move_force : float = 200.0
export var lift_force : float = 2.0
export var torque_rate : float = 200.0
export var linear_damping : float = 0.3
export var angular_damping : float = 0.5
export var default_linear_damping : float = -0.025
export var default_angular_damping : float = 0.3
export var engine_default_on : bool = false

# Properties
onready var collision_shape : CollisionShape = get_node("CollisionShape")
var vertical_velocity : float = 0.0
var falling_force : float = 0.0
var move_direction : Vector3 = Vector3()
var force_damping : bool = true
var torque_damping : bool = true
var gear_toggle : bool = true

# Engine configuration
var engine_power : float = 0.0
var engine_on : bool = false

# Raycast
var ground_distance : float = 0.0
var sea_distance : float = 0.0
var ground_visible : bool = false
var is_grounded : bool = false
var intersect_point : Vector3 = Vector3.ZERO

# Helper
onready var helpers_node : Spatial = get_node("HelicopterHelper")
var helper_dir : Spatial
var helper_rot : Spatial
var helper_yvel : Spatial

# Signal to feed the UI
signal ui_power_changed(power)
signal ui_angular_changed(velocity)
signal ui_update_compass(angle)
signal ui_messaging(level, msg)


# Ready
func _ready() -> void:
	# Engine power setup
	if self.engine_default_on:
		self.engine_on = true
		self.engine_power = 100
	else:
		self.engine_power = 0
	
	# Feed startup UI data
	emit_signal("ui_power_changed", self.engine_power)
	emit_signal("ui_update_compass", self.rotation.y)
	
	if helpers_node:
		helper_dir = helpers_node.get_node("Pivot/DirectionHelper")
		helper_rot = helpers_node.get_node("Pivot/RotationHelper")
		helper_yvel = helpers_node.get_node("Pivot/VerticalVelocity")


func _input(event) -> void:
	# Engine power toggle
	if Input.is_action_just_pressed("cl_engine_power"):
		if self.engine_on:
			emit_signal("ui_messaging", "INFO", "engine powered off")
		if !self.engine_on:
			emit_signal("ui_messaging", "INFO", "engine powered on")
		
		self.engine_on = !self.engine_on
		
		# If the power off set the rigidbody to sleep, and vice versa
		self.can_sleep = !self.engine_on
	
	# Gear toggle
	if event.is_action_pressed("cl_toggle_gear"):
		if !self.is_grounded:
			if self.ground_distance > 0.07:
				if self.gear_toggle:
					emit_signal("ui_messaging", "INFO", "gear up")
					
					# Configure collision offset
					collision_shape.translation = Vector3(0, 1.333, 0)
				if !self.gear_toggle:
					emit_signal("ui_messaging", "INFO", "gear down")
					collision_shape.translation = Vector3(0, 1, 0)
				
				self.gear_toggle = !self.gear_toggle
			else:
				emit_signal("ui_messaging", "ERROR", "helicopter touches the ground but gear isn't down")
		else:
			if !self.engine_on:
				emit_signal("ui_messaging", "WARN", "engine is powered off")
			else:
				emit_signal("ui_messaging", "ERROR", "helicopter landed, couldn't configure gear")


# Process
func _process(delta) -> void:
	engine_config(delta)
	damp_physics(helper_dir.translation.abs())
	
	if abs(self.angular_velocity.y) > 0:
		emit_signal("ui_angular_changed", self.angular_velocity.y * -1)
		emit_signal("ui_update_compass", self.rotation_degrees.y)
	
	if !is_grounded:
		self.axis_lock_angular_y = false
	else:
		self.axis_lock_angular_y = true


# Physics process
func _physics_process(delta) -> void:
	move(delta)
	get_ground_distance()


func _integrate_forces(state) -> void:
	var v : Vector3 = state.get_linear_velocity()
	# Only maintain vertical velocity when power is enough
	if self.engine_power > 85:
		#  Collective raise & lower
		if Input.is_action_pressed("cl_collective_raise"):
			self.vertical_velocity += helper_yvel.translation.y * get_process_delta_time()
		elif Input.is_action_pressed("cl_collective_lower"):
			self.vertical_velocity += helper_yvel.translation.y * get_process_delta_time()
		else:
			self.vertical_velocity = lerp(self.vertical_velocity, 0, get_process_delta_time())
		
		self.vertical_velocity = clamp(self.vertical_velocity, -4, 3)
		state.set_linear_velocity(Vector3(v.x, self.vertical_velocity * self.lift_force, v.z))
	else:
		# Capture ground distance sometime before falling, the falling force is relative to ground distance
		if self.engine_power > 83:
			self.falling_force = -self.ground_distance / 3
		
		# Interpolate vertical velocity down to the falling force to make it slowly falling down
		self.vertical_velocity = lerp(self.vertical_velocity, self.falling_force, 0.3 * get_process_delta_time())
		state.set_linear_velocity(Vector3(v.x, self.vertical_velocity, v.z))


func move(var delta: float) -> void:
	# Wait until power is enough to do movement
	if self.engine_power < 50:
		return
	
	# Force control from directional helper (from mouse & keyboard input)
	var force : Vector3 = self.transform.basis.xform(helper_dir.translation * self.move_force * delta)
	var position : Vector3 = self.transform.basis.xform(Vector3.ZERO)
	add_force(force, position)
	
	# Torque Pedal
	if Input.is_action_pressed("cl_pedal_right"):
		add_torque(Vector3.DOWN * self.torque_rate * delta)
	if Input.is_action_pressed("cl_pedal_left"):
		add_torque(Vector3.DOWN * -self.torque_rate * delta)
	
	# Add rotational force based on helper/move/mouse input left & right (-1 & 1)
	var torque : float = helper_dir.translation.x * (self.torque_rate / 100) * delta
	
	# Helper is way back, allows heavy rotation (torque * 1.5)
	if helper_dir.translation.z > 0.3:
		torque = helper_dir.translation.x * (self.torque_rate * 1.5) * delta
	# Helper is further front, allows light rotation (torque / 10)
	elif helper_dir.translation.z < -0.2:
		torque = helper_dir.translation.x * (self.torque_rate / 10) * delta
	# Helper is around the middle, tiny force (torque / 100)
	else:
		torque = helper_dir.translation.x * (self.torque_rate / 100) * delta
	add_torque(Vector3.DOWN * torque)


# Raycasting the ground
func get_ground_distance() -> void:
	var world_collision : PhysicsDirectSpaceState = get_world().direct_space_state
	var intersect : Dictionary = world_collision.intersect_ray(self.transform.origin + Vector3(0, 1, 0), Vector3(0, -300, 0))
	
	# If raycast intersects something, get the data
	if intersect:
		intersect_point = intersect.position
		self.ground_distance = $GroundPoint.get_global_transform().origin.y - intersect_point.y
		self.ground_visible = true
		self.is_grounded = self.ground_distance < 0.07 and self.gear_toggle
	else:
		# Sea level would be at Y:0
		self.sea_distance = $GroundPoint.get_global_transform().origin.y - 0
		self.ground_visible = false


# Conditional damping
func damp_physics(var m_offset : Vector3) -> void:
	var mx : bool = m_offset.x > 0.1								# Mouse X offset
	var mz : bool = m_offset.z > 0.1								# Mouse Y offset
	var cf : bool = Input.is_action_pressed("cl_cyclic_forward")	# Key W/UP pressed
	var cb : bool = Input.is_action_pressed("cl_cyclic_backward")	# Key S/DOWN pressed
	var cr : bool = Input.is_action_pressed("cl_cyclic_right")		# key D/RIGHT pressed
	var cl : bool = Input.is_action_pressed("cl_cyclic_left")		# key A/LEFT pressed
	var pr : bool = Input.is_action_pressed("cl_pedal_right")		# key E pressed
	var pl : bool = Input.is_action_pressed("cl_pedal_left")		# key Q pressed
	
	var m : Array = [mx, mz]										# Mouse input group
	var c : Array = [cf, cb, cr, cl]								# Cyclic input group
	var p : Array = [pr, pl, mx]									# Pedal input group (p)
	var f : Array = [!c.has(true), !m.has(true)]					# force group (f)
	
	self.force_damping = !f.has(false)								# Anything in (f) has false? then true
	self.torque_damping = !p.has(true)								# Anything in (p) has true? then false
	
	# If anything from move key isn't pressed or mouse isn't moved (f), then damp the linear velocity
	if self.force_damping: 
		self.linear_damp = self.linear_damping # Default preference: 0.3f
	else: 
		# If not then free to move
		self.linear_damp = self.default_linear_damping
	
	# If anything from pedal key isn't pressed or mouse isn't moved (p), then damp the angular velocity
	if self.torque_damping:
		self.angular_damp = self.angular_damping # Default preference: 2.0f
	else:
		# If not then free to rotate
		self.angular_damp = self.default_angular_damping
	
	# See what the hell is going on
	#printt(force_damping, torque_damping, c, m, p, f)


func engine_config(var delta : float) -> void:
	# Powering on and off is simply a linear interpolation to the desired number
	if self.engine_on:
		self.engine_power = lerp(self.engine_power, 100, 0.4 * delta)
		
		# Don't emit signal every single tick
		if self.engine_power < 99:
			emit_signal("ui_power_changed", self.engine_power)
	elif !self.engine_on:
		self.engine_power = lerp(self.engine_power, 0, 0.085 * delta)
		
		# Don't emit signal every single tick
		if self.engine_power > 0.5:
			emit_signal("ui_power_changed", self.engine_power)

