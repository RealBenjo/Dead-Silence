extends StaticBody2D
class_name Objective


@onready var interaction_collision: CollisionShape2D = $InteractionArea/CollisionShape2D
@export var objective_collision: CollisionShape2D
@export var parent: Node2D

var is_interacted := false ## Tracks if it's currently being carried

func _ready() -> void:
	# the interaction area shape MUST be a bigger than the objective shape
	# so the vision can see it and hence being actually interactible
	var size_offset = 15
	interaction_collision.shape.radius = objective_collision.shape.radius + size_offset

func _on_interacted(body: Node2D) -> void:
	is_interacted = not is_interacted
	
	# pick up or drop off if it is interacted or not
	if is_interacted:
		pick_up(body)
	else:
		drop_off()

func pick_up(body: Node2D) -> void:
	# 1. Turn off physical collision safely 
	objective_collision.set_deferred("disabled", true)
	
	# body that picks up (probs player)
	parent.reparent(body, false)
	parent.rotation = TAU
	parent.position = body.position

func drop_off() -> void:
	# needs to be called deferred so Godot is happy and doesn't panic
	# with collision calculations
	_deferred_drop_off.call_deferred()



func _deferred_drop_off() -> void:
	# drop back into the level map 
	# (it does not need to be a child of anything)
	parent.reparent(Globals.world_2d)
	
	objective_collision.set_deferred("disabled", false)
	
	# "Blink" the interaction area so the RayCast loses it for exactly a frame.
	interaction_collision.set_deferred("disabled", true)
	await get_tree().physics_frame
	interaction_collision.set_deferred("disabled", false)
