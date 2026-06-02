extends Area2D


func _on_body_entered(_body: Node2D) -> void:
	# man this is self explanatory i think. hover over swap_scenes() to find out more
	# Globals.world_2d.get_child(0) <--- this line is very important tho as it unloads
	# specifically the loaded level which is what we want to unload
	SceneManager.swap_scenes(Globals.menus.mission_select, Globals.gui, Globals.world_2d.get_child(0), "fade_to_black")
