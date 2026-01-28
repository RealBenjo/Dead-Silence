extends Node2D


const DAMAGE = 10
const SPEED = 5000

var direction: Vector2

@onready var bullet_path: RayCast2D = $BulletPath

func _process(delta: float) -> void:
	var prev_global = global_position
	var new_global = prev_global + direction * SPEED * delta
	
	# Put the ray at the start (world space)
	bullet_path.global_position = prev_global
	
	# Convert the target global position into the ray's *local* space
	bullet_path.target_position = bullet_path.to_local(new_global)
	
	# Force update if needed (ensures latest collision query)
	bullet_path.force_raycast_update()
	
	if bullet_path.is_colliding():
		var collider = bullet_path.get_collider()
		var layer = collider.collision_layer
	
		# Only layers 1 and 2 should trigger the hit signal
		if layer & ((1 << 0) | (1 << 1)):
			collider.take_damage(DAMAGE)
		queue_free()
	
	global_position = new_global

func _on_destroy_timer_timeout() -> void:
	queue_free()
