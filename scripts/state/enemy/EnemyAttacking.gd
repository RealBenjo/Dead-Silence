extends EnemyWalker
class_name EnemyAttacking


@onready var lose_player_timer: Timer = $"../../Timers/LosePlayerTimer"

@export var enemy: CharacterBody2D

func enter():
	print("enemy is attacking")
	
	enemy.state_vision_mult = 10.0

func physics_update(_delta: float):
	enemy.check_sound()
	
	if enemy.player_seen:
		lose_player_timer.stop()
		enemy.interest_pos = Globals.player_pos
		
		if enemy.can_attack:
			# TODO: play an animation, at a certain frame of the animation, the player takes big damage or something
			Globals.health -= enemy.damage
			print("attack")
		
	elif lose_player_timer.is_stopped():
		lose_player_timer.start()
	
	enemy.make_path(enemy.interest_pos)


func _on_lose_player_timer_timeout() -> void:
	transitioned.emit(self, "Searching")
