extends Node
class_name GameController

@onready var world_3d: Node3D = $World3D
@onready var world_2d: Node2D = $World2D
@onready var gui: Control = $GUI

func _ready() -> void:
	# 1. Register the controller
	GameManager.game_controller = self
	
	# 2. Assign the references to the Global
	GameManager.world_2d = world_2d
	GameManager.world_3d = world_3d
	GameManager.gui = gui
	
	# 3. Now it is safe to set the initial GUI scene
	GameManager.current_gui_scene = $GUI/MainMenu
