extends Node


var player_max_speed: float

var player_pos: Vector2
var is_using_mouse := true
 
var health = 100
var ammo = 3000 # TODO: set it to 30 for AR and other guns accordingly


# V might be useful code V 
#func wait(seconds: float) -> void:
	#await get_tree().create_timer(seconds).timeout
