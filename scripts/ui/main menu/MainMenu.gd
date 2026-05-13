extends Control


var levels := {
	lvl1 = "res://scenes/levels/outside.tscn"
}


func _on_start_pressed() -> void:
	GameManager.change_2d_scene(levels.lvl1, true, false)
