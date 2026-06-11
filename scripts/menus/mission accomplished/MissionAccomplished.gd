extends Control


func _on_continue_pressed() -> void:
	SceneManager.swap_scenes(Globals.hqs.hq1.path, Globals.world_2d, self, "fade_to_black")
