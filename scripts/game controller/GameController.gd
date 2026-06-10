extends Node
class_name GameControler


# this funny object holds ALL of the game (the gui the 2d and 3d world except i dont have anything 3d so...)
func _ready():
	Globals.world_2d = $World2D
	Globals.world_3d = $World3D
	Globals.gui = $GUI
