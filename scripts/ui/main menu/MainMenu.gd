extends Control


func _on_start_pressed() -> void:
	SceneManager.swap_scenes(Globals.levels.lvl1, Globals.world_2d, self, "fade_to_black")


func _on_settings_pressed() -> void:
	# make a settings menu
	# SceneManager.swap_scenes(Globals.levels.lvl1, Globals.world_2d, self, "fade_to_black")
	pass


func _on_exit_pressed() -> void:
	get_tree().quit()
