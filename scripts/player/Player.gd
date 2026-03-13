extends CharacterBody2D


signal bullet_signal(pos: Vector2, direction: Vector2)
signal sound_signal(pos: Vector2, loudness: float)
signal movement_signal(current_speed: float)
signal state_change_signal(vis_length: int, awareness_mult: float)

@onready var bullet: PackedScene = preload("res://scenes/player/bullet.tscn")
@onready var player_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var shoot_timer: Timer = $Timers/ShootTimer
@onready var move_sound_timer: Timer = $Timers/MoveSoundTimer
@onready var muzzle_end: Marker2D = $MuzzleEnd

# sound vars
const BULLET_LOUDNESS := 2000.0
var can_emit_move_sound := true

# state vars
var velocity_length: float ##real time speed of the player so the enemy AI can use it
var rotation_speed := 10.0 ##has no effect on gameplay

#multiplier vars
var speed_mult := 1.0
var vision_mult := 1.0
var awareness_mult := 1.0

# player attribute vars
var direction: Vector2
const SPEED := 300
var speed := SPEED
var weapon_zoom := 2.5
var can_attack := true
var player_direction: Vector2


func _ready() -> void:
	Globals.player_max_speed = SPEED

func _process(delta: float) -> void:
	handle_player_input()
	move_and_slide()
	handle_move_sound()
	
	#if Input.is_action_pressed("secondary_action"):
		#Engine.time_scale = 2.0
	
	# TODO: add controller support for this
	# rotate player
	if velocity != Vector2.ZERO:
		rotation = lerp_angle(rotation, velocity.angle(), rotation_speed * delta)
	
	Globals.player_pos = global_position
	
	# ADS zoom type shi (this is probably temporary, DONT try to make it nice just yet)
	if Input.is_action_pressed("secondary_action"):
		weapon_zoom = 2.5
	else:
		weapon_zoom = 10.0
	camera.offset = (get_global_mouse_position() - position) / weapon_zoom
	
	
	# get player direction for bullet placement and rotation
	player_direction = position.direction_to( get_global_mouse_position() )
	
	handle_shooting()



func handle_player_input() -> void:
	direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed # direction is ALWAYS A VECTOR
	
	if velocity != Vector2.ZERO:
		player_animation.play("s_walking")
	else:
		player_animation.pause()
		
	velocity_length = velocity.distance_to(Vector2.ZERO)
	
	movement_signal.emit(velocity_length)

func handle_shooting() -> void:
	#TODO: make it work with any weapon
	if Input.is_action_pressed("primary_action") and can_attack and Globals.ammo > 0:
		can_attack = false
		Globals.ammo -= 1
		shoot_timer.start()
		
		# emit the corresponding signals
		bullet_signal.emit(muzzle_end.global_position, player_direction)
		sound_signal.emit(muzzle_end.global_position, BULLET_LOUDNESS)

func handle_move_sound() -> void:
	if velocity != Vector2.ZERO and can_emit_move_sound:
		can_emit_move_sound = false
		
		# calculates the current speed which is good as a loudness meter aparently (works on controller too!)
		sound_signal.emit(global_position, velocity_length)
		move_sound_timer.start()
	elif velocity == Vector2.ZERO:
		can_emit_move_sound = true



# --- VAR UPDATER FOR STATES ---
func stance_update() -> void:
	speed = SPEED * speed_mult
	emit_signal("state_change_signal", vision_mult, awareness_mult)
	# TODO: collider, animation...



# premade signals

# timing between shots
func _on_shoot_timer_timeout() -> void:
	can_attack = true

func _on_move_sound_timer_timeout() -> void:
	can_emit_move_sound = true
