extends MarginContainer

#export (NodePath) var player
#export var zoom = 1.5
#
#onready var grid = $Grid
#onready var player_marker = $Grid/PlayerMarker
#onready var enemy_marker = $Grid/EnemyMarker
#
#onready var icons = {"enemy" : enemy_marker}
#
#var grid_scale # Size of the world down to the size of the map
#var markers = {}
#
#func _ready():
#	player_marker.position = grid.size / 2
#	grid_scale = grid.size / (get_viewport_rect().size * zoom)
#
#func _process(delta):
#	if !player:
#		return
#
#	player_marker.rotation = player.rotation
#	#.rotation + PI / 2
