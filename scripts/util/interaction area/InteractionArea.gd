extends Area2D

signal interactible_entered(interactible: Node2D)
signal interactible_exited(interactible: Node2D)

# Keep track of everyone currently in range
var interactibles_in_range: Array[Node2D] = []

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Interactible"):
		if not interactibles_in_range.has(body):
			interactibles_in_range.append(body)
			interactible_entered.emit(body)
			_update_interaction_globals()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Interactible"):
		interactibles_in_range.erase(body)
		interactible_exited.emit(body)
		_update_interaction_globals()

# Centralized logic to update your Global state
func _update_interaction_globals() -> void:
	# If the array size is greater than 0, there's at least one body nearby
	Globals.can_player_interact = interactibles_in_range.size() > 0
	
	# Optional: If you need to know WHICH one to talk to (e.g., the first one entered)
	if Globals.can_player_interact:
		Globals.current_target = interactibles_in_range[0]
	else:
		Globals.current_target = null
