extends Node2D


@export var stats: WeaponStats
@export var camera_shake_amount: float = 15.0

@export var debug_disable := false

@onready var player: Player = get_owner()

var bullet_scene: PackedScene = preload("res://scenes/player/bullet.tscn")
#var shoot_sound: AudioStream = preload("res://Sound/hitHurt.wav")

var inaccuracy: float
var is_cooldown := false
var cooldown_timer: Timer

func _ready():
	# get the inaccuracy of the weapon from the stats
	inaccuracy = stats.inaccuracy / 2
	
	cooldown_timer = Timer.new()
	cooldown_timer.name = "Cooldown Timer"
	cooldown_timer.wait_time = stats.firing_cooldown
	cooldown_timer.timeout.connect(on_cooldown_timer_finished)
	add_child(cooldown_timer)


func _physics_process(_delta: float) -> void:
	if debug_disable:
		return
	#if !player.alive or player.crafting:
		#return
	
	if Input.is_action_pressed("primary_action") && !is_cooldown:
		
		# Spawn a bullet and give it a rotation based on the angle between the firing position and
		# the cursor's position.
		# The bullet will use this rotation to decide its direction.
		var bullet: Bullet = bullet_scene.instantiate()
		var mouse_angle := (get_global_mouse_position() - global_position).angle() + deg_to_rad(randf_range(-inaccuracy, inaccuracy))
		
		# Assign attack information to bullet
		bullet.speed = stats.speed
		bullet.damage = stats.damage
		bullet.max_pierce = stats.max_pierce
		bullet.knockback_force = stats.knockback_force
		
		bullet.global_position = global_position + Vector2(15, 0).rotated(mouse_angle)
		bullet.rotation = mouse_angle
		
		get_tree().root.add_child(bullet)
		
		is_cooldown = true
		cooldown_timer.wait_time = stats.firing_cooldown
		cooldown_timer.start()
		
		#SoundManager.play_sound_pitched(shoot_sound, 0.1, 0.1)
		#CameraShake.add_trauma(camera_shake_amount)


func on_cooldown_timer_finished():
	is_cooldown = false
