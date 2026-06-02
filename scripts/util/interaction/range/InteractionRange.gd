extends Node2D


@onready var vision: VisionCone = $VisionCone

@export var range_length := 150 ## in pixels
@export_range(0, 360, 0.1, "degrees") var fov := 360.0

func _ready() -> void:
	# interaction range's vision cone will always search for Interactible
	# objects as it is it's only job lol
	vision.target_group = "Interactible"
	
	# also set the cone's length and fov so the parameters come from
	# InteractionRange and not the VisionCone
	vision.vis_length = range_length
	vision.fov = fov

func _on_target_seen(is_seen: bool) -> void:
	if is_seen:
		# the vision cone can only see interactible objects so
		# we can just get it's collider as it is 100% Interactible
		Globals.current_target = vision.get_collider()
	else:
		# Sight lost, clear the interaction state
		Globals.current_target = null
