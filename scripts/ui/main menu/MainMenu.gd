extends Control


func _on_start_pressed() -> void:
	SceneManager.swap_scenes(Globals.levels.lvl1, Globals.world_2d, self, "fade_to_black")
