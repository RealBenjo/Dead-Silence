extends Node


## emits whenever the player changes weapon
signal weapon_changed(new_weapon: WeaponStats)

## used in enemy's code for accelerating/decelerating
## awareness buildup
var player_max_speed: float
## player's position in 2D space expressed with a Vector2
var player_pos: Vector2
## wether or not the player can interact with
## an interaction area object
var can_player_interact := false
## the current target of the player's reach
var current_target: Node2D

var player_weapon: WeaponStats:
	set(weapon):
		player_weapon = weapon # save the new weapon
		weapon_changed.emit(weapon) # emit the change

var is_using_mouse := true
var health = 100

## stores amount of ammo for each ammo type.
## WARNING: total_ammo's children must have THE EXACT SAME NAME
## AS THE AMMO ITEM RESOURCE, otherwise weapons wont fire at all
var total_ammo: Dictionary = {
	l_ammo = 30,
	m_ammo = 35,
	h_ammo = 30,
	s_ammo = 30
}

## simple dictionary which holds all levels' paths
var levels: Dictionary = {
	lvl1 = "res://scenes/levels/outside.tscn"
}

## node which stores 2D scenes
var world_2d: Node2D
## node which stores 3D scenes
var world_3d: Node3D
## node which stores GUI scenes
var gui: CanvasLayer

# objective code
## the number of total objectives in a certain mission
var total_objectives: int
## the number of completed objectives in a certain mission.
## when this number is equal to or exceeds total_objectives
## the mission is completed and the player can leave
var completed_objectives: int:
	set(value):
		if completed_objectives >= total_objectives:
			# TODO: make a GUI popup notification type shi
			print("you win :)")

# V might be useful code V 
#func wait(seconds: float) -> void:
	#await get_tree().create_timer(seconds).timeout
