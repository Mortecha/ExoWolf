extends Node3D


@export var speed = 5
@export var rotation_speed = 2.1
var velocity = Vector3.ZERO
var rot = Vector3.ZERO
@export var explosion_effect: PackedScene

@export var target_path: NodePath
@onready var target: Node3D = get_node(target_path)



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = target.global_transform.origin - global_transform.origin
	direction = direction.normalized()
	
	var rotation_amount = direction.cross(global_transform.basis.z)
	rot.y = rotation_amount.y * rotation_speed * delta
	rot.x = rotation_amount.x * rotation_speed * delta
	rotate(Vector3.UP, rot.y)
	rotate(Vector3.RIGHT, rot.x)
	global_translate(-global_transform.basis.z * speed * delta)
	
	
func _on_Missile_body_entered(body):
	if body.name == "Player":
		var explosion = explosion_effect.instantiate()
		get_parent().add_child(explosion)
		explosion.global_transform.origin = global_transform.origin
		explosion.emitting = true
		#explode effect
		#hurt player
		queue_free()
	else:
		#explode_effect
		queue_free()
