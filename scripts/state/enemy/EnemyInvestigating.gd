extends EnemyWalker
class_name EnemyInvestigating


@onready var investigate_timer: Timer = $"../../Timers/InvestigationTimer"

@export var enemy: EnemyWalking

func enter():
	print("enemy is investigating")
	enemy.state_vision_mult = 1.1

func physics_update(_delta: float):
	enemy.check_sound()
	
	enemy.make_path(enemy.interest_pos)
	
	check_awareness(enemy.awareness, enemy.max_awareness)
	
	if enemy.nav.is_navigation_finished() and investigate_timer.is_stopped():
		investigate_timer.start()
		
		enemy.try_to_look_at_player()


func _on_investigation_timer_timeout() -> void:
	transitioned.emit(self, "Patrolling")
