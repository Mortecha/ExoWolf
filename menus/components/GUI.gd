extends CanvasLayer

onready var pause_menu = $PauseMenu
#onready var tab_menu_overlay = $TabMenuOverlay

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
		
	if event.is_action_pressed("pause"):
		pause_menu.is_paused = !pause_menu.is_paused
			
	if event.is_action_pressed("tab"):
		pass
		
