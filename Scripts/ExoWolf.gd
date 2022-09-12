extends KinematicBody

export var gravity : Vector3 = Vector3.DOWN * 9.8
var velocity : Vector3 = Vector3.ZERO

# Movement
var movement_speed : float = 0.0
export var max_movement_speed : float = -50.0
export var min_movement_speed : float = 30.0
var movement_acc_coef : float = 0.75
var move_damp_coef : float = 0.25

# Strafing
var strafe_speed : float = 0.0
var max_strafe_speed : float = 25.0

# Throttle
export var max_altitude : int = 50
var throttle = 1

# Rotor
onready var rotor = $Chassis/Rotor

func _ready():
	pass

func _physics_process(delta):
	#velocity += gravity * delta
	if(!is_on_floor()):
		handle_movement(delta)	
		#handle_rotation(delta)
		
	handle_throttle(delta)	
	velocity = move_and_slide(velocity, Vector3.UP)
	
func handle_movement(delta):
	var velocity_y : float = velocity.y
	velocity = Vector3.ZERO
	
	if Input.is_action_pressed("move_forwards"):
		move_forwards()				
	elif Input.is_action_pressed("move_backwards"):
		move_backwards()	
	else:
		dampen_movement()
	handle_stafing()
	velocity += transform.basis.z * movement_speed
	velocity += transform.basis.x * strafe_speed
	velocity.y = velocity_y

func move_forwards():
	if(movement_speed > max_movement_speed):
		movement_speed -= movement_acc_coef
	else:
		movement_speed = max_movement_speed

func move_backwards():
	if(movement_speed < min_movement_speed):
		movement_speed += movement_acc_coef
	else:
		movement_speed = min_movement_speed

func dampen_movement():
	if(movement_speed > 1):
		movement_speed -= move_damp_coef
	elif(movement_speed < -1):
		movement_speed += move_damp_coef
	else:
		movement_speed = 0

func handle_throttle(delta):
	if Input.is_action_pressed("increase_throttle"):
		throttle = 1
		rotor._set_rotor_to_boost()
	elif Input.is_action_pressed("decrease_throttle"):
		throttle = -1
		rotor._set_rotor_to_landed()
	else:
		throttle = 0
		rotor._set_rotor_to_flight()
	velocity += transform.basis.y * throttle
	
	if(transform.origin.y > max_altitude):
		transform.origin.y = max_altitude		
	
func handle_stafing():
	if Input.is_action_pressed("rotate_left"):	
		strafe_left()	
	elif Input.is_action_pressed("rotate_right"):	
		strafe_right()
	else:
		dampen_strafing()

func strafe_left():
	if(strafe_speed > max_movement_speed):
		strafe_speed -= movement_acc_coef
	else:
		strafe_speed = max_movement_speed

func strafe_right():
	if(strafe_speed < min_movement_speed):
		strafe_speed += movement_acc_coef
	else:
		strafe_speed = min_movement_speed

func dampen_strafing():
	if(strafe_speed > 1):
		strafe_speed -= move_damp_coef
	elif(strafe_speed < -1):
		strafe_speed += move_damp_coef
	else:
		strafe_speed = 0
