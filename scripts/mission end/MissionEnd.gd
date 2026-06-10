extends Area2D
class_name MissionEnd


func _on_body_entered(_body: Node2D) -> void:
	# check if player enters AND has a target with the objective group
	if Globals.current_target and Globals.current_target.parent_node.is_in_group("Objective"):
		deliver_objective(Globals.current_target.parent_node)

func deliver_objective(objective: Objective) -> void:
	# increment the completed objectives tracker
	Globals.completed_objectives += 1
	
	# drop the objective at safe place (the mission end area :) )
	if objective.has_method("drop_off"):
		objective.drop_off()
		Globals.current_target.remove_from_group("Interactible")
