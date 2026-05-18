extends Area2D

# 1. This is the signal you connected to your Survivor script manually 
# in the editor (which connects to the _on_interacted function)
signal interacted(body: Node2D)
@export var parent_node: Node2D

# 2. This is the function your Player script is calling when you press the button:
# Globals.current_target.interact(carry_pos)
func interact(body: Node2D) -> void:
	# 3. Fire the signal and pass the carry_pos (as the body) to the Survivor script!
	interacted.emit(body)
