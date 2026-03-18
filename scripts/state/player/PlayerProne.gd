extends PlayerStance
class_name PlayerProne

@export var player: CharacterBody2D

func enter():
	current_state = self
	
	if not player.is_node_ready():
		await player.ready
	
	player.current_stance = current_state
	
	player.player_animation.play("p_prone")
	player.speed_mult = 0.33
	player.vision_mult = 0.6
	player.awareness_mult = 0.8
	player.stance_update()
