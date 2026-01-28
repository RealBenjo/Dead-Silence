extends EnemyWalking


# premade signals

# calculate path finding only every 0.5s
func _on_path_find_timer_timeout() -> void:
	make_path(interest_pos)

#func _on_patrol_timer_timeout() -> void:
	#patrol_timer.wait_time = randf_range(patrol_time_min, patrol_time_max)
	#get_next_patrol_pos()
	#make_path(last_interest_pos)
