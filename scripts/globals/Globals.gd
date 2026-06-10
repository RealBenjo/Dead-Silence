extends Node


## emits whenever the player changes weapon which immediately
## updates the Weapon script to have and use the new stats
signal weapon_changed(new_weapon: WeaponStats)

## player_max_speed is used with player_cur_speed to calculate a multiplier
## for the enemies' awareness buildup speed
var player_max_speed: float
## tracks the player's current speed
var player_cur_speed: float

## player's position in 2D space expressed with a Vector2
var player_pos: Vector2

## the current target of the player's reach
var current_target: Node2D

## tracks what weapon the player has equiped and notifies
## any connected script about a change
var player_weapon: WeaponStats:
	set(weapon):
		player_weapon = weapon # save the new weapon
		weapon_changed.emit(weapon) # emit the change

## track wether or not the player is using m&k or gamepad to dynamically
## change input methods and make the player be able to switch the two anytime
var is_using_mouse := true

## tracks player's current health so it is consistent through scenes
var health = 100

## holds all enemy data which needs to be the identical
## across all enemies, like multipliers and such
var enemy: Dictionary = {
	vision_mult = 1.0,
	awareness_mult = 1.0
}



## stores amount of ammo for each ammo type.
## WARNING: total_ammo's children must have THE EXACT SAME NAME
## AS THE AMMO ITEM RESOURCE, otherwise weapons wont fire at all
var total_ammo: Dictionary = {
	l_ammo = 30,
	m_ammo = 35,
	h_ammo = 30,
	s_ammo = 30
}



## simple dictionary which holds all levels' data (like path and name)
var levels: Dictionary = {
	lvl1 = preload("res://resources/levels/missions/lvl1.tres")
}

## simple dictionary which holds all head quarters' data (like path and name)
var hqs: Dictionary = {
	hq1 = preload("res://resources/levels/headquarters/hq1.tres")
}

## simple dictionary which holds all menus' paths
var menus: Dictionary = {
	main_menu = "res://scenes/menus/main menu/main_menu.tscn",
	mission_select = "res://scenes/menus/mission select/mission_select.tscn"
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

## the number of completed objectives in a certain mission. when this number
## is equal to or exceeds total_objectives the mission is completed and
## the player can leave to HQ
var completed_objectives: int:
	set(value):
		if value >= total_objectives:
			SceneManager.swap_scenes(hqs.hq1.path, world_2d, world_2d.get_child(0), "fade_to_black")



# V might be useful code V 
#func wait(seconds: float) -> void:
	#await get_tree().create_timer(seconds).timeout
