extends Node3D

@export var Bullet: PackedScene
@export var muzzle_speed = 30
@export var time_between_shots = 0.15

@onready var rof_timer = $Timer
@onready var gun_sound_player = $AudioStreamPlayer3D

var can_shoot = true

var bullet
var scene_root
var target_position

func _ready():
	scene_root = get_tree().get_root().get_children()[0] 
	rof_timer.wait_time = time_between_shots

func _physics_process(delta):
	pass

func set_target(target):
	target_position = target

func shoot():
	if can_shoot:
		gun_sound_player.play()
		bullet = Bullet.instantiate()
		bullet.global_transform = $Muzzle.global_transform	
		scene_root.add_child(bullet)
		can_shoot = false
		rof_timer.start()

func _on_Timer_timeout():
	can_shoot = true
