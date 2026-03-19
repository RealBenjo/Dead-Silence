extends EnemyWalking


@onready var state_machine: Node = $StateMachine

# premade signals

# calculate path finding only every 0.5s
func _on_path_find_timer_timeout() -> void:
	make_path(interest_pos)

# make helper object that emits signal eevery frame
# so you can have multiple update functions in one object pretty much
