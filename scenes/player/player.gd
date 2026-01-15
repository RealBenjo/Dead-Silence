extends CharacterBody2D


signal bullet_signal(pos: Vector2, direction: Vector2)
signal sound_signal(pos: Vector2, loudness: float)
signal state_change_signal(vis_length: int, awareness_mult: float)

@onready var bullet: PackedScene = preload("res://scenes/player/bullet.tscn")
@onready var camera: Camera2D = $Camera2D
@onready var shoot_timer: Timer = $Timers/ShootTimer
@onready var move_sound_timer: Timer = $Timers/MoveSoundTimer
@onready var muzzle_end: Marker2D = $MuzzleEnd

# sound vars
const BULLET_LOUDNESS: float = 2000.0
var moving_loudness: float
var can_emit_move_sound: bool = true

# state vars
##amount of seconds that count as a "button held". if a player holds the "state_toggle" button for less than this time, 
##the player character will NOT go prone, only crouch (depends on the current state of the player)
@export var hold_threshold: float = 0.1
enum state {STAND, CROUCH, PRONE}
var current_state: state = state.STAND #TODO: load from save file
var state_button_held_time: float = 0.0
var is_button_held: bool = false
##if user didn't trigger hold but the threshold is surpassed, handle_hold_press() runs and this turns TRUE. 
##This prevents handle_tap() from running, after we already handled hold.
var has_triggered_hold: bool = false

var direction: Vector2
const SPEED: float = 300
var speed: float = SPEED
var weapon_zoom: float = 2.5
var can_shoot: bool = true

var player_direction

func _process(delta: float) -> void:
	check_state_change_button(delta)
	check_player_input()
	move_and_slide()
	handle_move_sound()
	
	# TODO: add controller support for this
	# rotate player
	look_at( get_global_mouse_position() )
	
	Globals.player_pos = global_position
	
	
	# ADS zoom type shi (this is probably temporary, DONT try to make it nice just yet)
	if Input.is_action_pressed("secondary_action"):
		weapon_zoom = 2.5
	else:
		weapon_zoom = 10.0
	camera.offset = (get_global_mouse_position() - position) / weapon_zoom
	
	
	# get player direction for bullet placement and rotation
	player_direction = (get_global_mouse_position() - position).normalized()
	
	handle_shooting()



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("state_toggle"):
		is_button_held = true
		state_button_held_time = 0.0
		has_triggered_hold = false
	
	elif event.is_action_released("state_toggle"):
		is_button_held = false
	
		# If we never triggered the hold, treat it as a tap
		if not has_triggered_hold:
			handle_tap()



# -- AUX ---
func check_state_change_button(delta: float) -> void:
	if is_button_held:
		state_button_held_time += delta
		
		if state_button_held_time >= hold_threshold and not has_triggered_hold:
			handle_hold_press()
			has_triggered_hold = true

func check_player_input() -> void:
	direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed # direction is ALWAYS A VECTOR

func handle_shooting() -> void:
	if Input.is_action_pressed("primary_action") and can_shoot and Globals.ammo > 0:
		can_shoot = false
		Globals.ammo -= 1
		shoot_timer.start()
		
		# emit the corresponding signals
		bullet_signal.emit(muzzle_end.global_position, player_direction)
		sound_signal.emit(muzzle_end.global_position, BULLET_LOUDNESS)

func handle_move_sound() -> void:
	if velocity != Vector2.ZERO and can_emit_move_sound:
		can_emit_move_sound = false
		
		# calculates the current speed which is good as a loudness meter aparently (works on controller too!)
		moving_loudness = sqrt( pow(velocity.x, 2) + pow(velocity.y, 2) )
		sound_signal.emit(global_position, moving_loudness)
		move_sound_timer.start()
	elif velocity == Vector2.ZERO:
		can_emit_move_sound = true



# --- STATE HANDLERS ---
func handle_tap() -> void:
	match current_state:
		state.STAND:
			enter_crouch()
		state.CROUCH:
			enter_stand()
		_: # if we ever implement more states, remember to replace this with: state.PRONE
			enter_crouch()

func handle_hold_press() -> void:
	match current_state:
		state.PRONE:
			enter_stand()
		_:
			enter_prone()


# --- STATE TRANSITIONS ---
func enter_stand() -> void:
	var speed_mult = 1.0
	var vision_mult = 1.0
	var awareness_mult = 2.0
	state_update(state.STAND, speed_mult, vision_mult, awareness_mult)

func enter_crouch() -> void:
	var speed_mult = 0.66
	var vision_mult = 0.8
	var awareness_mult = 1.5
	state_update(state.STAND, speed_mult, vision_mult, awareness_mult)

func enter_prone() -> void:
	var speed_mult = 0.33
	var vision_mult = 0.6
	var awareness_mult = 0.8
	state_update(state.STAND, speed_mult, vision_mult, awareness_mult)

# --- VAR UPDATER FOR STATES ---
func state_update(this_state: state, new_speed_mult: float, new_vision_mult: float, new_awareness_mult: float) -> void:
	current_state = this_state
	speed = SPEED * new_speed_mult
	emit_signal("state_change_signal", new_vision_mult, new_awareness_mult)
	# TODO: collider, animation...



# premade signals

# timing between shots
func _on_shoot_timer_timeout() -> void:
	can_shoot = true

func _on_move_sound_timer_timeout() -> void:
	can_emit_move_sound = true
