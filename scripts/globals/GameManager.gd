extends Node


var game_controller: GameController

var world_2d: Node2D
var world_3d: Node3D
var gui: Control

var current_2d_scene
var current_3d_scene
var current_gui_scene

# A single helper function to handle the logic for all types
func _switch_scene(new_scene_path: String, container: Node, current_ref: Node, delete: bool, keep_running: bool) -> Node:
	# 1. Handle old scene
	if current_ref != null:
		if delete:
			current_ref.queue_free()
		elif keep_running:
			current_ref.visible = false
		else:
			container.remove_child(current_ref)
	
	# 2. Load and Instantiate
	var res = load(new_scene_path)
	print(res)
	if not res:
		push_error("Scene path invalid: " + new_scene_path)
		return null
		
	var instance = res.instantiate()
	print(instance)
	container.add_child(instance)
	return instance

# The public API for your other scripts
func change_gui_scene(path: String, delete := true, keep := false):
	current_gui_scene = _switch_scene(path, gui, current_gui_scene, delete, keep)

func change_2d_scene(path: String, delete := true, keep := false):
	current_2d_scene = _switch_scene(path, world_2d, current_2d_scene, delete, keep)

func change_3d_scene(path: String, delete := true, keep := false):
	current_3d_scene = _switch_scene(path, world_3d, current_3d_scene, delete, keep)
