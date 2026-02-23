extends EnemyWalker
class_name EnemyInvestigating


@onready var investigate_timer: Timer = $"../../Timers/InvestigationTimer"

@export var enemy: CharacterBody2D

func enter():
	print("enemy is investigating")
	enemy.state_vision_mult = 1.1

func physics_update(_delta: float):
	enemy.check_sound()
	check_awareness(enemy.awareness, enemy.max_awareness)
	
	enemy.make_path(enemy.interest_pos)
	
	if enemy.nav.is_navigation_finished() and investigate_timer.is_stopped():
		investigate_timer.start()


func _on_investigation_timer_timeout() -> void:
	transitioned.emit(self, "Patrolling")
