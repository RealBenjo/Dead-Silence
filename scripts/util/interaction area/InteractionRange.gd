extends Node2D

@export var vision_cone: VisionCone

func _ready() -> void:
	if not vision_cone:
		push_error("InteractionNode: No VisionCone assigned in the inspector!")
	
	vision_cone.target_group = "Interactible"

func _on_vision_cone_target_seen(is_seen: bool) -> void:
	if is_seen:
		# The VisionCone already verified the collider is the closest target 
		# and in the correct group, so we can trust it.
		Globals.current_target = vision_cone.get_collider()
		Globals.can_player_interact = true
	else:
		# Sight lost, clear the interaction state
		Globals.current_target = null
		Globals.can_player_interact = false
