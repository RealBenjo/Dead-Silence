extends Area2D
class_name MissionEnd

var total_objectives: int = 0
var objectives_delivered: int = 0

func _ready() -> void:
	# 1. Count exactly how many objectives exist when the level starts
	total_objectives = get_tree().get_nodes_in_group("Objective").size()
	print("Total objectives to rescue: ", total_objectives)

func _on_body_entered(body: Node2D) -> void:
	print(Globals.current_target)
	# 2. Check if player enters AND has a target with the objective group
	if body.is_in_group("Player") and Globals.current_target and Globals.current_target.parent_node.is_in_group("Objective"):
		deliver_objective()

func deliver_objective() -> void:
	# 3. Add to our score
	objectives_delivered += 1
	
	# complete the objective or sum
	complete_obj()
	
	# 4. Clean the player's hands so they can grab the next guy
	Globals.current_target = null
	Globals.can_player_interact = false
	
	# 6. Check if we hit the Win Condition
	if objectives_delivered >= total_objectives:
		print("you win :)")
		# Trigger your level transition, win screen, or next sequence here!


func complete_obj() -> void:
	if Globals.current_target.parent_node.has_method("drop_off"):
		Globals.current_target.parent_node.drop_off()
		Globals.current_target.remove_from_group("Interactible")
