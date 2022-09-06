extends RigidBody

var throttle = 1
var rotation_amount = 0
var max_rotation_amount = 50

var movement_amount = 0

func _ready():
	pass

func _physics_process(delta):
	handle_throttle()
	handle_rotation()
	handle_movement()
	
func handle_throttle():
	if Input.is_action_pressed("space"):
		throttle = 4
	elif Input.is_action_pressed("left_shift"):
		throttle = -2
	else:
		throttle = 1
	add_central_force(Vector3.UP * weight * throttle)
	
func handle_rotation():
	if Input.is_action_pressed("a"):
		rotation_amount = max_rotation_amount
	elif Input.is_action_pressed("d"):
		rotation_amount = -max_rotation_amount
	else:
		rotation_amount = 0
	add_torque(Vector3.UP * rotation_amount)

func handle_movement():
	if Input.is_action_pressed("w"):
		movement_amount = 10
		
	elif Input.is_action_pressed("s"):
		movement_amount = -10
	else:
		movement_amount = 0
	#add_central_force(Vector3.FORWARD. * movement_amount)
	
