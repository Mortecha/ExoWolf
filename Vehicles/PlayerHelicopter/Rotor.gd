extends MeshInstance

var rotor_landed_speed : float = 2.5
var rotor_flight_speed : float = 13.3
var rotor_boost_speed : float = 22.3

func _process(delta):
	rotate_y(rotor_boost_speed * delta)
