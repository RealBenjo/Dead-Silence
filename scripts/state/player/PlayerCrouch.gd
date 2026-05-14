extends PlayerStance
class_name PlayerCrouch

@export var player: CharacterBody2D

func enter():
	current_state = self
	
	if not player.is_node_ready():
		await player.ready
	
	player.current_stance = current_state
	
	player.rotation_mult = 0.6
	player.speed_mult = 0.66
	player.vision_mult = 0.8
	player.awareness_mult = 1.5
	player.stance_update()
