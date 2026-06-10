extends StaticBody2D
class_name Survivor

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var area_collision: CollisionShape2D = $InteractionArea/CollisionShape2D

var is_interacted := false ## Tracks if currently being carried

func _ready() -> void:
	animation.play("idle")

func _on_interacted(body: Node2D) -> void:	
	is_interacted = not is_interacted
	
	if is_interacted:
		# 1. Turn off physical collision safely 
		collision.set_deferred("disabled", true)
		
		# 2. Glue to the player's center
		reparent(body, false)
		rotation = TAU
		position = Vector2(-30,0)
		
	else:
		# 3. Drop back into the level map
		reparent_to_map()
		
		collision.set_deferred("disabled", false)
		animation.play("idle")
		
		# "Blink" the interaction area so the RayCast loses it for exactly a frame.
		area_collision.set_deferred("disabled", true)
		await get_tree().physics_frame
		area_collision.set_deferred("disabled", false)

func reparent_to_map() -> void:
	var level_map = get_tree().current_scene
	reparent(level_map, true)
