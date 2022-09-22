extends MeshInstance

var rotor_speed : float = 0.0
var rotor_landed_speed : float = 13.3
export var rotor_flight_speed : float = 22.3

enum RotorState {stopped, landed, flight}
var rotor_state

func _ready():
	rotor_state = RotorState.flight

func _process(delta):
	match rotor_state:
		RotorState.stopped:
			rotor_speed = 0.0
			continue
		RotorState.landed:
			rotor_speed = rotor_landed_speed
			continue
		RotorState.flight:
			rotor_speed = rotor_flight_speed
			continue
	rotate_y(rotor_speed * delta)

func _set_rotor_to_stopped():
	rotor_state = RotorState.stopped
	
func _set_rotor_to_landed():
	rotor_state = RotorState.landed
	
func _set_rotor_to_flight():
	rotor_state = RotorState.flight
