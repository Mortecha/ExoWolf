extends Node

@export var StartingWeapon: PackedScene

var hand : Marker3D
var equipped_weapon : Node3D

func _ready():
	hand = get_parent().find_child("Hand")
	
	if StartingWeapon:
		equip_weapon(StartingWeapon)
		
func equip_weapon(weapon_to_equip):
	if equipped_weapon:
		print("Deleting current weapon")
		equipped_weapon.queue_free()
	else:
		print("No weapon equipped")
		equipped_weapon = weapon_to_equip.instantiate()
		hand.add_child(equipped_weapon)

func shoot():
	if equipped_weapon:
		equipped_weapon.shoot()
