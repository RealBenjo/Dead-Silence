extends PlayerStance
class_name PlayerStand

@export var player: CharacterBody2D

func enter():
	current_state = self
	
	player.speed_mult = 1.0
	player.vision_mult = 1.0
	player.awareness_mult = 2.0
	player.stance_update()
