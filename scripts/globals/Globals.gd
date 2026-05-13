extends Node

signal weapon_changed(new_weapon: WeaponStats)

var player_max_speed: float
var player_pos: Vector2

var player_weapon: WeaponStats:
	set(value):
		player_weapon = value # save the new weapon
		weapon_changed.emit(value) # emit the change

var is_using_mouse := true
var health = 100

## stores amount of ammo for each ammo type.
## WARNING: total_ammo's children must have THE EXACT SAME NAME
## AS THE AMMO ITEM RESOURCE, otherwise weapons wont fire at all
var total_ammo: Dictionary = {
	l_ammo = 30,
	m_ammo = 500,
	h_ammo = 30,
	s_ammo = 30
}

## simple dictionary which holds all levels' paths
var levels: Dictionary = {
	lvl1 = "res://scenes/levels/outside.tscn"
}

var world_2d: Node2D
var world_3d: Node3D
var gui: CanvasLayer


# V might be useful code V 
#func wait(seconds: float) -> void:
	#await get_tree().create_timer(seconds).timeout
