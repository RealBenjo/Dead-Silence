extends EnemyWalking


@onready var state_machine: Node = $StateMachine
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

# premade signals

# calculate path finding only every 0.5s
func _on_path_find_timer_timeout() -> void:
	make_path(interest_pos)

# make helper object that emits signal eevery frame
# so you can have multiple update functions in one object pretty much

func _on_updater_fixed_update(_delta: float) -> void:
	var _cur_state = state_machine.current_state.get_script().get_global_name()
	
	if velocity == Vector2.ZERO:
		animation.play("idle")
	else:
		animation.play("walking")
