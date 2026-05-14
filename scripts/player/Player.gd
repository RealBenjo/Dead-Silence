extends CharacterBody2D
class_name Player

signal movement_signal(current_speed: float)
signal state_change_signal(vis_length: int, awareness_mult: float)

@onready var bullet: PackedScene = preload("res://scenes/player/bullet.tscn")
@onready var player_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var move_sound_timer: Timer = $Timers/MoveSoundTimer
@onready var sound_emitter: SoundEmitter = $SoundEmitter
@onready var weapon: Weapon = $Weapon

# sound vars
var can_emit_move_sound := true

# stance vars
var current_stance: Node # Assuming this holds your stance node
var velocity_length: float 
var rotation_speed := 10.0 
var rotation_mult := 1.0

# multiplier vars
var speed_mult := 1.0
var vision_mult := 1.0
var awareness_mult := 1.0

# player attribute vars
var direction: Vector2
const MAX_AIM_SPEED := 50.0
const MAX_SPEED := 300.0
var speed := MAX_SPEED
var weapon_zoom := 2.5


func _ready() -> void:
	Globals.player_max_speed = MAX_SPEED

func _process(delta: float) -> void:
	handle_player_input()
	move_and_slide()
	handle_move_sound()
	update_animations() # Decoupled animation logic!
	
	# rotate player
	if velocity != Vector2.ZERO and not weapon.is_aimed:
		rotation = lerp_angle(rotation, velocity.angle(), rotation_speed * rotation_mult * delta)
	
	Globals.player_pos = global_position

func handle_player_input() -> void:
	# UI Input
	if Input.is_action_just_pressed("tool_select"):
		camera.is_wheel_open = true
	elif Input.is_action_just_released("tool_select"):
		camera.is_wheel_open = false
	
	# Movement Input
	direction = Input.get_vector("left", "right", "up", "down")
	if weapon.is_aimed:
		velocity = direction * MAX_AIM_SPEED
	else:
		velocity = direction * speed
	
	velocity_length = velocity.length() 
	movement_signal.emit(velocity_length)

# --- NEW: Dedicated Animation Manager ---
func update_animations() -> void:
	# Priority 1: Aiming
	if weapon.is_aimed:
		player_animation.play("aiming")
		
		# Read the frame directly from the equipped weapon's stats!
		# (Make sure to add 'aim_frame' to WeaponStats.gd)
		if Globals.player_weapon:
			player_animation.frame = Globals.player_weapon.aim_frame
			
		# Optional: You might want the player to face the mouse while aiming
		rotation = lerp_angle(rotation, (get_global_mouse_position() - global_position).angle(), 0.5)
		return # Stop here so walking animations don't override aiming
		
	# Priority 2: Moving
	if velocity != Vector2.ZERO:
		# Normalize the animation speed based on input amount
		player_animation.speed_scale = direction.length() 
		
		# Matching the node's name directly is much safer than getting the script's global name
		handle_stance_anims()
			
	# Priority 3: Idle
	else:
		handle_stance_anims()
		
		player_animation.pause()
		# You could also play an idle animation here later instead of pausing

func handle_stance_anims() -> void:
	match current_stance.name:
		"Stand": player_animation.play("s_walking")
		"Crouch": player_animation.play("c_crouching")
		"Prone": player_animation.play("p_prone")

func handle_move_sound() -> void:
	if velocity != Vector2.ZERO and can_emit_move_sound:
		can_emit_move_sound = false
		sound_emitter.create_sound(global_position, velocity_length)
		move_sound_timer.start()
	elif velocity == Vector2.ZERO:
		can_emit_move_sound = true

func stance_update() -> void:
	speed = MAX_SPEED * speed_mult
	state_change_signal.emit(vision_mult, awareness_mult)

func _on_move_sound_timer_timeout() -> void:
	can_emit_move_sound = true
