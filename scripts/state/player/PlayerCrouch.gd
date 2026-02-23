extends PlayerStance
class_name PlayerCrouch

@export var player: CharacterBody2D

func enter():
	current_state = self
	
	player.speed_mult = 0.66
	player.vision_mult = 0.8
	player.awareness_mult = 1.5
	player.stance_update()
