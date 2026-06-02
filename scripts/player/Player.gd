extends CharacterBody2D
class_name Player


@onready var bullet: PackedScene = preload("res://scenes/player/bullet.tscn")
@onready var player_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var move_sound_timer: Timer = $Timers/MoveSoundTimer
@onready var sound_emitter: SoundEmitter = $SoundEmitter
@onready var weapon: Weapon = $Weapon
@onready var carry_pos: Node2D = $CarryPosition

# sound vars
var can_emit_move_sound := true

# stance vars
var current_stance: Node # Assuming this holds your stance node
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

var cur_speed := 0.0


func _ready() -> void:
	Globals.player_max_speed = MAX_SPEED
	
	# when player is loaded into a scene it checks if there is a 
	# weapon already selected. if it is it equips that weapon
	if Globals.player_weapon:
		weapon.stats = Globals.player_weapon

func _process(delta: float) -> void:
	handle_player_input()
	move_and_slide()
	handle_move_sound()
	update_animations() # Decoupled animation logic!
	
	# rotate player
	if velocity != Vector2.ZERO and not weapon.is_aimed:
		# interpolates between 2 angles in radians with a weigth ("speed" if you will)
		rotation = lerp_angle(rotation, velocity.angle(), rotation_speed * rotation_mult * delta)
	
	# keep player position up to date
	Globals.player_pos = global_position
	# keep player speed up to date
	cur_speed = velocity.length()
	Globals.player_cur_speed = cur_speed



func handle_player_input() -> void:
	# UI Input
	if Input.is_action_just_pressed("tool_select"):
		camera.is_wheel_open = true
	elif Input.is_action_just_released("tool_select"):
		camera.is_wheel_open = false
	
	# movement input
	direction = Input.get_vector("left", "right", "up", "down")
	if weapon.is_aimed:
		velocity = direction * MAX_AIM_SPEED
	else:
		velocity = direction * speed
	
	# if player click the interact button and it has an actual
	# interaction target, then interact with the target
	if Input.is_action_just_pressed("interact") and Globals.current_target:
		Globals.current_target.interact(carry_pos)



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
		
	# Priority 2: Moving
	elif  cur_speed != 0.0:
		# Normalize the animation speed based on input amount
		player_animation.speed_scale = direction.length() 
		
		# Matching the node's name directly is much safer than getting the script's global name
		handle_stance_anims()
			
	# Priority 3: Idle
	else:
		handle_stance_anims()
		
		player_animation.pause()

func handle_stance_anims() -> void:
	match current_stance.name:
		"Stand": player_animation.play("s_walking")
		"Crouch": player_animation.play("c_crouching")
		"Prone": player_animation.play("p_prone")

func handle_move_sound() -> void:
	# if player isn't moving
	if cur_speed <= 0.0:
		move_sound_timer.stop()
		can_emit_move_sound = true
	
	# if player is moving and can emit move sound
	elif can_emit_move_sound:
		sound_emitter.create_sound(global_position, Globals.player_cur_speed)
		move_sound_timer.start()
		can_emit_move_sound = false

## stance_update() runs only through the state machine, not
## through the player script itself
func stance_update() -> void:
	speed = MAX_SPEED * speed_mult
	
	# the enemy multipliers are placed in a dictionary for the
	# enemies to access
	Globals.enemy.vision_mult = vision_mult
	Globals.enemy.awareness_mult = awareness_mult

func _on_move_sound_timer_timeout() -> void:
	can_emit_move_sound = true
