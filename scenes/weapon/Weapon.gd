extends Sprite2D


var bullet_scene: PackedScene = preload("res://scenes/player/bullet.tscn")
#var shoot_sound: AudioStream = preload("res://Sound/hitHurt.wav")
@onready var reload_timer: Timer = $ReloadTimer
@onready var player: Player = get_owner()
@onready var muzzle: Marker2D = $Muzzle

@export var stats: WeaponStats
@export var camera_shake_amount: float = 15.0

@export var debug_disable := false


var ammo_type: Item
var magazine_size: int
var cur_ammo: int
var inaccuracy: float
var is_cooldown := false
var cooldown_timer: Timer

func _ready():
	# get the default weapon from Globals
	if Globals.player_weapon:
		stats = Globals.player_weapon
	
	# connect the Globals' signal to this script to listen for stat changes
	Globals.weapon_changed.connect(on_weapon_changed)
	
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
	# return if the ammo_type doesn't exist to prevent crashes
	if not ammo_type:
		print("ammo_type does NOT exist")
		print(ammo_type)
		return
	
	# grab the string name of the ammo
	var current_ammo_key: String = ammo_type.item_name.to_lower()
	
	if cur_ammo > 0 and reload_timer.is_stopped() and Input.is_action_pressed("primary_action") and !is_cooldown:
		Globals.total_ammo[current_ammo_key] -= 1
		cur_ammo -= 1
		print(cur_ammo)
		if cur_ammo <= 0:
			reload_timer.start()
		
		# spawn a bullet and give it a rotation based on the angle between the firing position and
		# the cursor's position.
		# The bullet will use this rotation to decide its direction.
		var bullet: Bullet = bullet_scene.instantiate()
		var mouse_angle := (get_global_mouse_position() - muzzle.global_position).angle() + deg_to_rad(randf_range(-inaccuracy, inaccuracy))
		
		# assign attack information to bullet
		bullet.speed = stats.speed
		bullet.damage = stats.damage
		bullet.max_pierce = stats.max_pierce
		bullet.knockback_force = stats.knockback_force
		
		bullet.global_position = muzzle.global_position + Vector2().rotated(mouse_angle)
		bullet.rotation = mouse_angle
		
		get_tree().root.add_child(bullet)
		
		is_cooldown = true
		cooldown_timer.wait_time = stats.firing_cooldown
		cooldown_timer.start()
		
		#SoundManager.play_sound_pitched(shoot_sound, 0.1, 0.1)
		#CameraShake.add_trauma(camera_shake_amount)

func on_weapon_changed(new_weapon_stats: WeaponStats) -> void:
	stats = new_weapon_stats
	
	magazine_size = stats.magazine_size
	# this is kind of ass since you can
	# reload by switching weapons :(
	cur_ammo = magazine_size
	ammo_type = stats.ammo_type
	texture = stats.texture
	inaccuracy = stats.inaccuracy / 2
	reload_timer.wait_time = stats.reload_time
	reload_timer.stop()

func on_cooldown_timer_finished():
	is_cooldown = false


func _on_reload_timer_timeout() -> void:
	cur_ammo = magazine_size
	print(cur_ammo)
