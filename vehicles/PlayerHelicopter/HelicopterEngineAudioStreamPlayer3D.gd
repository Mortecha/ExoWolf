extends AudioStreamPlayer3D

func _process(delta):
	if not playing:
		play()
