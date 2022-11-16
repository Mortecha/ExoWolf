extends Node3D

@export var speed = 70

var forward_direction
const KILL_TIME = 2
var timer = 0

func _physics_process(delta):
	forward_direction = global_transform.basis.z.normalized()
	global_translate(forward_direction * speed * delta)

	timer += delta
	if timer >= KILL_TIME:
		queue_free()


func _on_Area_body_entered(body: Node):
	if body.has_node("Stats"):
		var stats_node = body.find_child("Stats") as Stats
		stats_node.take_hit(1)
	queue_free()
