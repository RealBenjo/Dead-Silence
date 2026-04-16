extends Node2D
class_name Bullet

@onready var bullet_path: RayCast2D = $BulletPath
@onready var sound_emitter: SoundEmitter = $SoundEmitter

var damage := 10.0
var speed := 5000.0
var max_pierce := 1.0
var knockback_force := 10.0
var loudness := 5000.0


func _ready() -> void:
	sound_emitter.create_sound(global_position, loudness)

func _process(delta: float) -> void:
	# 1. Calculate how far the bullet will move this frame
	var distance := speed * delta
	
	# 2. Point the raycast "forward" (local X-axis) by that distance
	bullet_path.target_position = Vector2.RIGHT * distance
	bullet_path.force_raycast_update()
	
	# 3. Check for collisions BEFORE moving
	if bullet_path.is_colliding():
		var collider = bullet_path.get_collider()
		
		# if a bullet hits a hitboxcomponent, the hitbox will take damage
		if collider is HitboxComponent:
			var attack = Attack.new()
			attack.attack_damage = damage
			# Bonus: We can now use the exact collision point for better accuracy!
			attack.attack_position = bullet_path.get_collision_point() 
			
			collider.damage(attack)
		
		# TODO: should make some particles on hit or something
		queue_free() # if the bullet hits anything -> gets deleted
		return # Important: stop executing so the bullet doesn't move past the target
	
	# 4. If no collision, move the bullet forward based on its rotation
	global_position += Vector2.RIGHT.rotated(rotation) * distance

func _on_destroy_timer_timeout() -> void:
	queue_free()
