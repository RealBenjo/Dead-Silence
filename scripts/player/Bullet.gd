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
		
		# if a bullet hits a hitboxcomponent, the hitbox will take damage
		if collider is HitboxComponent:
			var attack = Attack.new()
			attack.attack_damage = DAMAGE
			attack.attack_position = global_position
			
			collider.damage(attack)
		queue_free() # if the bullet hits anything -> gets deleted
	
	global_position = new_global

func _on_destroy_timer_timeout() -> void:
	queue_free()
