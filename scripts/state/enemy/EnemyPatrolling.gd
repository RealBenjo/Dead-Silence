extends EnemyWalker
class_name EnemyIdle


@onready var patrol_timer: Timer = $"../../Timers/PatrolTimer"

@export var enemy: CharacterBody2D

func _ready() -> void:
	# when the enemy is spawned it will have a SET patrol time, that does NOT change during runtime
	patrol_timer.wait_time = randf_range(enemy.patrol_time_min, enemy.patrol_time_max)

func enter():
	print("enemy is patrolling")
	enemy.state_vision_mult = 1.0

func physics_update(_delta: float):
	if enemy.sound_heard:
		enemy.interest_pos = enemy.sound_position
		transitioned.emit(self, "Investigating")
		return
	
	check_awareness(enemy.awareness, enemy.max_awareness, "Patrolling")
	
	if enemy.nav.is_navigation_finished() and patrol_timer.is_stopped():
		patrol_timer.start()


func _on_patrol_timer_timeout() -> void:
	enemy.get_next_patrol_pos()
