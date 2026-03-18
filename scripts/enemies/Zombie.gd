extends EnemyWalking


# premade signals

# calculate path finding only every 0.5s
func _on_path_find_timer_timeout() -> void:
	make_path(interest_pos)
