extends KinematicBody

export var gravity : Vector3 = Vector3.DOWN * 9.8
export var speed : float = 25.0
export var rotation_speed : float = 0.85

var velocity : Vector3 = Vector3.ZERO

var throttle = 1
var rotation_amount = 0
var max_rotation_amount = 50

var movement_amount = 0

func _ready():
	pass

func _physics_process(delta):
	#velocity += gravity * delta
	if(!is_on_floor()):
		get_input(delta)
		handle_rotation(delta)
	
	handle_throttle(delta)
	#handle_movement()
	
	velocity = move_and_slide(velocity, Vector3.UP)
	
func get_input(delta):
	var velocity_y : float = velocity.y
	velocity = Vector3.ZERO
	
	if Input.is_action_pressed("w"):
		velocity += -transform.basis.z * speed		

		#rotation.x = 11.25
	elif Input.is_action_pressed("s"):
		velocity += transform.basis.z * speed
		rotation.x = 11.25
	else:
		rotation.x = 0
	velocity.y = velocity_y
	

func handle_throttle(delta):
	if Input.is_action_pressed("space"):
		throttle = 1
	elif Input.is_action_pressed("left_shift"):
		throttle = -1
	else:
		throttle = 0
	velocity += transform.basis.y * throttle
	
func handle_rotation(delta):
	if Input.is_action_pressed("a"):	
		rotate_y(rotation_speed * delta)	
	elif Input.is_action_pressed("d"):	
		rotate_y(-rotation_speed * delta)

func handle_movement():
	if Input.is_action_pressed("w"):
		movement_amount = 10
		
	elif Input.is_action_pressed("s"):
		movement_amount = -10
	else:
		movement_amount = 0
	#add_central_force(Vector3.FORWARD. * movement_amount)
	
