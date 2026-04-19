extends Node

signal weapon_changed(new_weapon: WeaponStats)

var player_max_speed: float
var player_pos: Vector2

var player_weapon: WeaponStats:
	set(value):
		player_weapon = value # Actually save the new weapon
		weapon_changed.emit(value) # Announce the change

var is_using_mouse := true
var health = 100
## stores amount of ammo for each ammo type.
## WARNING: ammo's children must have THE EXACT SAME NAME
## AS THE AMMO ITEM, otherwise weapons wont fire at all
var ammo := {
	l_ammo = 30,
	m_ammo = 30,
	h_ammo = 30,
	s_ammo = 30
}


# V might be useful code V 
#func wait(seconds: float) -> void:
	#await get_tree().create_timer(seconds).timeout
