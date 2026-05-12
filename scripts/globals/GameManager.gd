extends Node


var game_controller: GameController

@export var world_2d: Node2D
@export var gui: Control

var current_2d_scene
var current_gui_scene

func _ready() -> void:
	current_gui_scene = $GUI/MainMenu

func change_gui_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_gui_scene != null:
		if delete:
			current_gui_scene.queue_free() # removes node fully (not in RAM anymore)
		elif keep_running:
			current_gui_scene.visible = false # keeps in RAM and running
		else:
			gui.remove_child(current_gui_scene) # keeps in RAM, does NOT run
	
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_gui_scene = new
