extends Node3D

@onready var target = $"../ExoWolf"
@export var distance = 4.0
@export var height = 2.0

func _ready():
	pass # Replace with function body.

func _process(_delta):
	transform.origin.x = target.transform.origin.x
	transform.origin.z = target.transform.origin.z
		
