extends CharacterBody2D
class_name EnemyWalking


# node vars
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var patrol_timer: Timer = $Timers/PatrolTimer

# basic functionality vars
@export var speed: float = 100.0
@export var damage: int = 10
var can_attack: bool = false

# vision vars
@onready var vision: VisionCone = $VisionCone
@export var default_vision_length: int = 500
var vision_length: Vector2 = Vector2.RIGHT * default_vision_length
var vision_mult: float = 1.0
var state_vision_mult: float = 1.0

# awareness vars
@export var max_awareness: float = 300.0
var awareness: float = 0.0

# state vars
var player_seen: bool = false
var sound_heard: bool = false

# pathfinding vars
var interest_pos: Vector2
var sound_position: Vector2

# patrol vars
@export_group("Timers")
@export var patrol_time_min: float = 10.0 ## in seconds
@export var patrol_time_max: float = 30.0 ## in seconds
var patrol: Array
var patrol_index: int = 0

# player vars
var player_speed_mult: float = 1.0 ## it is clamped between 1.0 - 2.0
var player_velocity: float = 0.0
var awareness_mult: float = 1.0 ## comes from the player via signal (if player is prone -> multip is lower)


func _ready() -> void:
	# the nav agent REALLY needs to know the max_speed for avoidance!
	nav.max_speed = speed
	get_next_patrol_pos()
	
	# set the vision length :)
	vision.VISION_LENGTH = default_vision_length


func _physics_process(_delta):
	vision.vision_multipliers = [vision_mult, state_vision_mult]
	update_awareness()
	
	# if an enemy is not pathfinding anymore, don't go further than this if statement
	if nav.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	else:
		# TODO: find a way to avoid the usage of this dumb line here (it is so dumb grrrrr)
		patrol_timer.stop()
	
	var next_path_pos = nav.get_next_path_position()
	var dir = (next_path_pos - global_position).normalized()
	
	# the actual velocity used by the enemy is a so called safe_velocity. it is a signal from the nav agent
	var desired_velocity = dir * speed
	nav.set_velocity(desired_velocity)
	
	# smooth rotation for ALL states
	if dir.length() > 0.1:
		rotation = lerp_angle(rotation, dir.angle(), 0.1)


# --- AWARENESS LOGIC ---
func update_awareness() -> void:
	if player_seen:
		# 50 is so the distance is never negative (player's hitbox size matters)
		# 250 is just so it is not as extreme and we can manage it easier with the multipliers
		var distance := ( vision_length.x + 50 - global_position.distance_to(Globals.player_pos) ) / 250
		
		awareness += distance * awareness_mult * player_speed_mult
		awareness = clamp(awareness, 0.0, max_awareness)
		
	else:
		# gradual linear decay
		awareness -= 4
		awareness = clamp(awareness, 0.0, max_awareness) # awareness can only be between 0 and max_awareness
	
	#print(awareness)


# --- PLAYER STATE CHANGES HANDLING ---
##the player tells the enemy the new player dependent multiplier
func player_state_handler(vis_mult: float, aware_mult: float) -> void:
	vision_mult = vis_mult
	awareness_mult = aware_mult

##the player tells the enemy it's new speed
func player_speed_handler(new_velocity_length: float) -> void:
	player_velocity = new_velocity_length
	player_speed_mult = player_velocity / Globals.player_max_speed + 1.0


# --- AUX ---

func get_next_patrol_pos() -> void:
	if patrol_index > patrol.size() - 1:
		patrol_index = 0
	interest_pos = patrol.get(patrol_index)
	patrol_index += 1


##will offset the given Vector2D by an integer amount in a square fashion, not a circle
func vector_offset(pos: Vector2, offset_amount: int) -> Vector2:
	var amountX = randi_range(offset_amount * -1, offset_amount)
	var amountY = randi_range(offset_amount * -1, offset_amount)
	var rand_offset = Vector2(amountX, amountY)
	return pos + rand_offset

func make_path(target_position: Vector2) -> void:
	nav.target_position = target_position

func check_sound() -> bool:
	if sound_heard:
		interest_pos = sound_position
		return true
	return false


# engine signals

# very important so enemies try to avoid each other and not just run into each other
func _on_nav_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()


func _on_death() -> void:
	queue_free()


func _on_target_seen(is_seen: bool) -> void:
	player_seen = is_seen
