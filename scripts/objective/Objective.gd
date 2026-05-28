extends StaticBody2D
class_name Objective


@onready var interaction_collision: CollisionShape2D = $InteractionArea/CollisionShape2D
@export var objective_collision: CollisionShape2D
@export var parent: Node2D

var is_interacted := false ## Tracks if it's currently being carried

func _ready() -> void:
	var size_offset = 15
	interaction_collision.shape.radius = objective_collision.shape.radius + size_offset

func _on_interacted(body: Node2D) -> void:
	is_interacted = not is_interacted
	
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
	# 3. Drop back into the level map
	parent.reparent(Globals.world_2d)
	
	objective_collision.set_deferred("disabled", false)
	
	# "Blink" the interaction area so the RayCast loses it for exactly a frame.
	interaction_collision.set_deferred("disabled", true)
	await get_tree().physics_frame
	interaction_collision.set_deferred("disabled", false)
