extends Node2D
class_name Weapon


var bullet_scene: PackedScene = preload("res://scenes/player/bullet.tscn")
#var shoot_sound: AudioStream = preload("res://Sound/hitHurt.wav")
@onready var player: Player = get_owner()
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var reload_timer: Timer = $ReloadTimer
@onready var muzzle: Marker2D = $Muzzle
@onready var weapon_sprite2d: Sprite2D = $Sprite2D
@onready var sound_emitter: SoundEmitter = $SoundEmitter


@export_group("Attributes")
@export var stats: WeaponStats
@export var camera_shake_amount: float = 15.0 # TODO: make it do something maybe if i have time for it

@export_group("Behaviour")
@export var only_show_when_aimed := false
@export var only_fires_when_aimed := false

@export_group("Debug")
@export var debug_disable := false


# weapon stats pretty much
var ammo_type: Item ## the type of ammo a weapon uses
var magazine_size: int ## the amount of ammo in a weapon before it needs to be reloaded
var cur_ammo: int ## current amount of ammo in weapon's magazine
var current_ammo_key: String ## hold the String name of the current ammo
var inaccuracy: float ## deviation of bullet paths in degrees

# important booleans
var is_cooldown := false ## if it's on cooldown
var is_aimed := false ## if the weapon is being aimed

func _ready():
	# get the default weapon from Globals if it exists
	if Globals.player_weapon:
		stats = Globals.player_weapon
	
	# connect the Globals' signal to this script to listen for stat changes
	Globals.weapon_changed.connect(on_weapon_changed)
	
	cooldown_timer.wait_time = stats.firing_cooldown


func _physics_process(_delta: float) -> void:
	if debug_disable:
		return
	#if !player.alive or player.crafting:
		#return
	
	# return if the ammo_type doesn't exist to prevent crashes
	if not ammo_type:
		printerr("ammo_type does NOT exist")
		return
	
	# find out if player is aiming the weapon
	is_aimed = Input.is_action_pressed("aim_weapon")
	
	# this will make the weapon visible when it's aimed if that's what you want
	if only_show_when_aimed:
		if is_aimed:
			visible = true
		else:
			visible = false
	
	# if it isn't allowed to fire when it isn't being aimed, return out of the function
	if only_fires_when_aimed and not is_aimed:
		return
	
	# grab the string name of the ammo
	current_ammo_key = ammo_type.item_name.to_lower()
	
	if Input.is_action_just_pressed("reload_weapon") and cur_ammo < magazine_size and reload_timer.is_stopped():
		on_reload()
	
	if not (Input.is_action_pressed("primary_fire") and reload_timer.is_stopped() and cur_ammo > 0 and !is_cooldown):
		return
	
	# if all conditions for firing a weapon are passed fire the weapon
	fire_weapon()

## handles the firing of the weapon
func fire_weapon() -> void:
	cur_ammo -= 1
	stats.current_ammo = cur_ammo
	if cur_ammo <= 0:
		on_reload()
	
	# spawn a bullet and give it a rotation based on the angle between the firing position and
	# the cursor's position.
	# The bullet will use this rotation to decide its direction.
	var bullet: Bullet = bullet_scene.instantiate()
	
	# TODO: this needs to be updated to work with controller too
	var mouse_angle := (get_global_mouse_position() - muzzle.global_position).angle() + deg_to_rad(randf_range(-inaccuracy, inaccuracy))
	
	# assign attack information to bullet
	bullet.speed = stats.speed
	bullet.damage = stats.damage
	bullet.max_pierce = stats.max_pierce
	bullet.knockback_force = stats.knockback_force
	
	bullet.global_position = muzzle.global_position
	bullet.rotation = mouse_angle
	
	Globals.world_2d.get_child(0).add_child(bullet)
	
	# when the bullet is put in the world we can safely assume the weapon created
	# some noise, therefore this line runs
	sound_emitter.create_sound(muzzle.global_position, stats.loudness)
	
	is_cooldown = true
	cooldown_timer.wait_time = stats.firing_cooldown
	cooldown_timer.start()
	
	#SoundManager.play_sound_pitched(shoot_sound, 0.1, 0.1)
	#CameraShake.add_trauma(camera_shake_amount)

func on_weapon_changed(new_weapon_stats: WeaponStats) -> void:
	
	# stats.reload_time_left is used to continue reloading
	# after switching to a different weapon 
	stats.reload_time_left = reload_timer.time_left
	
	stats = new_weapon_stats
	stats.init_stats()
	
	# ammo and mag stats
	magazine_size = stats.magazine_size
	cur_ammo = stats.current_ammo
	ammo_type = stats.ammo_type
	
	# just the inaccuracy of the weapon
	inaccuracy = stats.inaccuracy / 2
	
	# visuals of the weapon
	weapon_sprite2d.region_rect = stats.weapon_sprite_region
	weapon_sprite2d.position = stats.weapon_sprite_pos
	
	# muzzle of the weapon
	muzzle.position = stats.muzzle_pos
	
	# if the weapon was being reloaded when it got switched
	# it continues reloading from that time
	if stats.is_reloading:
		reload_timer.start(stats.reload_time_left)
	else:
		reload_timer.stop()
	
	reload_timer.wait_time = stats.reload_time

func on_reload() -> void:
	stats.is_reloading = true
	reload_timer.start()


func _on_cooldown_timer_timeout() -> void:
	is_cooldown = false

func _on_reload_timer_timeout() -> void:
	# update the global amount of ammo that the weapon uses
	Globals.total_ammo[current_ammo_key] -= magazine_size - cur_ammo
	stats.is_reloading = false
	cur_ammo = magazine_size
