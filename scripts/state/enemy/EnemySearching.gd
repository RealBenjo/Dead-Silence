extends EnemyWalker
class_name EnemySearching


@onready var search_timer: Timer = $"../../Timers/SearchTimer"
@onready var stop_search_timer: Timer = $"../../Timers/StopSearchTimer"

@export var enemy: EnemyWalking

func enter():
	print("enemy is searching")
	enemy.state_vision_mult = 1.2
	stop_search_timer.start()

func physics_update(_delta: float):
	if enemy.check_sound():
		search_timer.stop()
	
	check_awareness(enemy.awareness, enemy.max_awareness)
	
	if enemy.nav.is_navigation_finished() and search_timer.is_stopped():
		search_timer.start()
		
		enemy.try_to_look_at_player()


func _on_search_timer_timeout() -> void:
	enemy.interest_pos = enemy.vector_offset(enemy.global_position, 500)
	enemy.make_path(enemy.interest_pos)

func _on_stop_search_timer_timeout() -> void:
	transitioned.emit(self, "Patrolling")
