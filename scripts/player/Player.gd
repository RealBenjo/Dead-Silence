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

# stance vars
var current_stance
var velocity_length: float ##real time speed of the player so the enemy AI can use it
var rotation_speed := 10.0 ##has no effect on gameplay
var rotation_mult := 1.0

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
	
	# rotate player
	if velocity != Vector2.ZERO:
		rotation = lerp_angle(rotation, velocity.angle(), rotation_speed * rotation_mult * delta)
	
	Globals.player_pos = global_position	
	
	# get player direction for bullet placement and rotation
	player_direction = position.direction_to( get_global_mouse_position() )
	
	handle_shooting()



func handle_player_input() -> void:
	if Input.is_action_just_pressed("tool_select"):
		camera.is_wheel_open = true
	elif Input.is_action_just_released("tool_select"):
		camera.is_wheel_open = false
	
	direction = Input.get_vector("left", "right", "up", "down")
	var dir_amount = direction.distance_to(Vector2.ZERO)
	player_animation.speed_scale = dir_amount
	velocity = direction * speed
	
	if velocity != Vector2.ZERO:
		match current_stance.get_script().get_global_name():
			"PlayerStand":
				player_animation.play("s_walking")
			"PlayerCrouch":
				player_animation.play("c_crouching")
			"PlayerProne":
				player_animation.play("p_prone")
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
