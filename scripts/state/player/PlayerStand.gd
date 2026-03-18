extends PlayerStance
class_name PlayerStand

@export var player: CharacterBody2D

func enter():
	current_state = self
	
	if not player.is_node_ready():
		await player.ready
	
	player.current_stance = current_state
	
	player.player_animation.play("s_walking")
	player.speed_mult = 1.0
	player.vision_mult = 1.0
	player.awareness_mult = 2.0
	player.stance_update()
