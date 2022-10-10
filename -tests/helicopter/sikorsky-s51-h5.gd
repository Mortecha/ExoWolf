extends VehicleBody

var horse_power = 50
var accel_speed = 10

var steer_angle = deg2rad(30)
var steer_speed = 3

var brake_power = 40
var brake_speed = 40

var grounded = false

func _physics_process(delta):
	# Throttle
	var throt_input = -Input.get_action_strength("player_forwards") + Input.get_action_strength("player_backwards")
	engine_force = lerp(engine_force, throt_input * horse_power, accel_speed * delta)
	
	# Steering
	var steer_input = -Input.get_action_strength("player_left") + Input.get_action_strength("player_right")
	steering = lerp_angle(steering, steer_input * steer_angle, steer_speed * delta)
	
	# Breaking
	var brake_input = Input.get_action_strength("player_increase_throttle")
	brake = brake_input * brake_power

func _integrate_forces(state):
		
	var ver_input = -Input.get_action_strength("player_forwards") + Input.get_action_strength("player_backwards")
	var hor_input = -Input.get_action_strength("player_left") + Input.get_action_strength("player_right")
	
	# Landing / Taking off
	if grounded == true:
		if Input.is_action_pressed("player_increase_throttle") && ver_input == -1:
			grounded = false
	else:
		engine_force = 0
		steering = 0
		brake = 0
		if $back_left.is_in_contact() || $back_right.is_in_contact() || $front.is_in_contact():
			grounded = true
			
	# Air movement
	if grounded == false && abs(rotation_degrees.x) <= 90 && abs(rotation_degrees.z) <= 90:
		if Input.is_action_pressed("player_increase_throttle"):
			linear_velocity.y = -ver_input * transform.basis.y.y * (horse_power / 20)
			angular_velocity = Vector3.ZERO
			angular_velocity.y = -hor_input
		else:
			linear_velocity.y = 0
			angular_velocity = (transform.basis.x * ver_input) + (-transform.basis.z * hor_input)		
		linear_velocity.x = transform.basis.y.x * (horse_power / 5)
		linear_velocity.z = transform.basis.y.z * (horse_power / 5)
		
	# Animation
	$main_propellor.rotation.y += 0.4
	$back_propellor.rotation.x -= 0.4
