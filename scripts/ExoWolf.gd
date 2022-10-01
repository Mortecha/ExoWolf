extends KinematicBody

export var gravity : Vector3 = Vector3.DOWN * 9.8
var velocity : Vector3 = Vector3.ZERO

const MAX_ALTITUDE = 15

const TILT_COEF = 15 		# The max amount of tilt, Higher value less tilt  
const TILT_RESP = 4 		# The responsiveness of the tilting

# Movement
var movement_speed : float = 0.0
export var max_movement_speed : float = -35.0
export var min_movement_speed : float = 35.0
var movement_acc_coef : float = 0.75
var move_damp_coef : float = 0.25

# Strafing
var strafe_speed : float = 0.0
var max_strafe_speed : float = 25.0

var global_direction : Vector3

onready var turret_rotator = $"Chassis/Turret Barrel Rotator"
onready var turret_base = $"Chassis/Turret Barrel Rotator/Turret Base"
onready var barrels = $"Chassis/Turret Barrel Rotator/Turret Base/Barrels"
onready var sensor_mount = $Chassis/Mount
onready var sensor = $Chassis/Mount/Sensors

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
	set_global_direction()
	
	var velocity_y : float = velocity.y
	velocity = Vector3.ZERO
	
	if Input.is_action_pressed("player_forwards"):
		move_forwards()				
	elif Input.is_action_pressed("player_backwards"):
		move_backwards()	
	else:
		dampen_movement()
		
	handle_stafing()
	
	velocity += transform.basis.z * movement_speed
	velocity += transform.basis.x * strafe_speed
	velocity.y = velocity_y

	# Tilt based on movement
	rotation.x = lerp_angle(rotation.x, global_direction.z / TILT_COEF, TILT_RESP)
	rotation.z = lerp_angle(rotation.z, -global_direction.x / TILT_COEF, TILT_RESP)

func set_global_direction():
	global_direction.x = Input.get_axis("player_left", "player_right")
	global_direction.y = Input.get_axis("player_decrease_throttle", "player_increase_throttle")
	global_direction.z = Input.get_axis("player_forwards", "player_backwards")

	# Limit the input to a length of 1. length_squared is faster to check.
	if global_direction.length_squared() > 1: 
		global_direction /= global_direction.length()

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
	velocity += transform.basis.y * global_direction.y 
	
	# Dampen vertical movement if no input
	if global_direction.y == 0:
		velocity.y = 0
	
	# Altitude limit check
	if transform.origin.y > MAX_ALTITUDE:
		velocity.y = 0
		transform.origin.y = MAX_ALTITUDE		
	
func handle_stafing():
	if Input.is_action_pressed("player_left"):	
		strafe_left()	
	elif Input.is_action_pressed("player_right"):	
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

func rotate_turret():
	pass
	
func fire_minigun():
	pass
