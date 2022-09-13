extends MeshInstance3D

var rotor_speed : float = 0.0
var rotor_landed_speed : float = 2.5
var rotor_flight_speed : float = 13.3
var rotor_boost_speed : float = 22.3

enum RotorState {landed, flight, boost}
var rotor_state

func _ready():
	rotor_state = RotorState.landed

func _process(delta):
	match rotor_state:
		RotorState.landed:
			rotor_speed = rotor_landed_speed
			continue
		RotorState.flight:
			rotor_speed = rotor_flight_speed
			continue
		RotorState.boost:
			rotor_speed = rotor_boost_speed
			continue
	rotate_y(rotor_speed * delta)

func _set_rotor_to_landed():
	rotor_state = RotorState.landed
	
func _set_rotor_to_flight():
	rotor_state = RotorState.flight
	
func _set_rotor_to_boost():
	rotor_state = RotorState.boost
