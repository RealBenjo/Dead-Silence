extends PlayerStance
class_name PlayerProne

@export var player: CharacterBody2D

func enter():
	current_state = self
	
	player.speed_mult = 0.33
	player.vision_mult = 0.6
	player.awareness_mult = 0.8
	player.stance_update()
