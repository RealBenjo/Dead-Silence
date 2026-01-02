extends CharacterBody2D
class_name EnemyWalking


# node vars
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var vision: RayCast2D = $Vision

# vision vars
@export_range(0, 360, 0.1, "degrees") var fov: float = 90.0
@export var default_vision_length: int = 500
var vision_length: Vector2 = Vector2.RIGHT * default_vision_length

# basic functionality vars
@export var speed: float = 100.0
@export var health: int = 100
@export var damage: int = 10

# awareness
@export var max_awareness: float = 300.0
var awareness: float = 0.0
var awareness_mult: float = 1.0

# state vars
enum state {PATROLLING, INVESTIGATING, SEARCHING, ATTACKING}
var current_state: state = state.PATROLLING
var player_seen: bool = false
var sound_heard: bool = false
@onready var lose_player_timer: Timer = $Timers/LosePlayerTimer
@onready var search_timer: Timer = $Timers/SearchTimer

# pathfinding vars
var interest_pos: Vector2
var sound_position: Vector2

# patrol vars
@onready var patrol_timer: Timer = $Timers/PatrolTimer
@export var patrol_time_min: float = 10.0
@export var patrol_time_max: float = 30.0
var patrol: Array
var patrol_index: int = 0



func _ready() -> void:
	get_next_patrol_pos()
	patrol_timer.wait_time = randf_range(patrol_time_min, patrol_time_max)
	
	# set the vision length
	update_vision_length(1.0)
	
	lose_player_timer.wait_time = 30.0
	search_timer.wait_time = 180.0



func _physics_process(_delta):
	update_vision_cone()
	handle_vision()
	update_awareness()
	state_machine()
	
	print(patrol_timer.time_left)
	
	#
	#match current_state:
		#state.PATROLLING:
			#print("patrolling")
		#state.INVESTIGATING:
			#print("investigating")
		#state.SEARCHING:
			#print("searching")
		#state.ATTACKING:
			#print("attacking")
	
	# if an enemy is not pathfinding anymore, don't go further than this if statement
	if nav.is_navigation_finished():
		velocity = Vector2.ZERO
		return
	
	var next_path_pos = nav.get_next_path_position()
	var dir = (next_path_pos - global_position).normalized()
	
	var desired_velocity = dir * speed
	nav.set_velocity(desired_velocity)
	
	# smooth rotation for ALL states
	if dir.length() > 0.1:
		rotation = lerp_angle(rotation, dir.angle(), 0.1)



# --- VISION HANDLING ---
func handle_vision() -> void:
	if vision.is_colliding():
		var collider = vision.get_collider()
		if collider.is_in_group("Player"):
			player_seen = true
			sound_heard = false
		else:
			player_seen = false
	else:
		player_seen = false



# --- AWARENESS LOGIC ---
func update_awareness() -> void:
	if player_seen:
		# 50 is so the distance is never negative (player's hitbox size matters)
		# 250 is just so it is not as extreme and we can manage it easier with the awareness_mult
		var distance := ( vision_length.x + 50 - global_position.distance_to(Globals.player_pos) ) / 250
		
		awareness +=  distance * awareness_mult
		awareness = clamp(awareness, 0.0, max_awareness)
	else:
		# gradual linear decay
		awareness -= 4
		awareness = clamp(awareness, 0.0, max_awareness) # awareness can only be between 0 and max_awareness
		
	if awareness >= max_awareness and current_state != state.ATTACKING:
		enter_attacking()
	
	#print(awareness)


# --- PLAYER STATE CHANGES HANDLING ---
func player_state_handler(vis_mult: float, aware_mult: float) -> void:
	update_vision_length(vis_mult)
	awareness_mult = aware_mult

func update_vision_length(new_vision_mult: float) -> void:
	vision_length = Vector2.RIGHT * default_vision_length * new_vision_mult
	vision.target_position = vision_length



# --- STATE MACHINE ---
##called every physics frame, simply switches what behaviour an enemy will have depending
##on which state it currently is in (current_state)
func state_machine() -> void:
	match current_state:
		state.PATROLLING:
			process_patrolling()
		state.INVESTIGATING:
			process_investigating()
		state.SEARCHING:
			process_searching()
		state.ATTACKING:
			process_attacking()



# --- STATE PROCESSING ---
func process_patrolling() -> void:
	if sound_heard:
		enter_investigating(sound_position)
	
	check_awareness()
	
	if !nav.is_navigation_finished():
		patrol_timer.stop()
	
	if nav.is_navigation_finished() and patrol_timer.is_stopped():
		patrol_timer.start()


func process_investigating() -> void:
	check_awareness()
	
	nav.target_position = interest_pos
	# TODO: after reaching the interest_pos, go back to patrolling after some time
	if nav.is_navigation_finished():
		enter_patrolling()


func process_searching() -> void:
	check_awareness()
	
	# TODO: slow this tf down. this ends up looking like ants on an ant hill. yuck
	if nav.is_navigation_finished():
		interest_pos = vector_offset(global_position, 500)
		make_path(interest_pos)
	
	if search_timer.is_stopped():
		enter_patrolling()


func process_attacking() -> void:
	if player_seen:
		interest_pos = Globals.player_pos
	else:
		look_at(interest_pos)

	update_vision_length(10.0)
	make_path(interest_pos)

	if nav.is_navigation_finished() and !player_seen and lose_player_timer.is_stopped():
		lose_player_timer.start()



# --- STATE ENTER ---
func enter_patrolling() -> void:
	current_state = state.PATROLLING
	#patrol_timer.start()

##enemy will investigate the given position
func enter_investigating(invest_pos: Vector2) -> void:
	current_state = state.INVESTIGATING
	interest_pos = invest_pos
	sound_heard = false

func enter_searching() -> void:
	current_state = state.SEARCHING
	search_timer.start()

func enter_attacking() -> void:
	current_state = state.ATTACKING
	lose_player_timer.start()



# --- AUX ---
func update_vision_cone() -> void:
	# get the global player direction from the enemy in radiants
	var player_direction = (vision.get_parent().to_local(Globals.player_pos) - vision.position).angle()
	
	# clamp the vision cone depending on the FOV (in degrees)
	if rad_to_deg(player_direction) > fov/2:
		player_direction = deg_to_rad(fov/2)
	elif rad_to_deg(player_direction) < -fov/2:
		player_direction = deg_to_rad(-fov/2)
	
	vision.rotation = player_direction

func get_next_patrol_pos() -> void:
	if patrol_index > patrol.size() - 1:
		patrol_index = 0
	interest_pos = patrol.get(patrol_index)
	patrol_index += 1

##will offset the given Vector2D by an integer amount in a square fashion, not a circle
func vector_offset(pos: Vector2, offset_amount: int) -> Vector2:
	var amount = randi_range(offset_amount * -1, offset_amount)
	var rand_offset = Vector2(amount, amount)
	return pos + rand_offset

func make_path(target_position: Vector2) -> void:
	nav.target_position = target_position

##if an enemy is more aware than a certain max_awareness percentage, it will enter the appropriate state
func check_awareness() -> void:
	# TODO: test if entering a state only once is actually OK (probs is but who knows)
	if awareness > max_awareness * 0.5 and current_state != state.INVESTIGATING:
		enter_investigating(Globals.player_pos)
	elif awareness > max_awareness * 0.7 and current_state != state.SEARCHING:
		enter_searching()
	elif awareness >= max_awareness and current_state != state.ATTACKING:
		enter_attacking()



# --- DAMAGE ---
func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()

func die():
	# TODO: animation or whatever
	queue_free()



# premade signals
func _on_patrol_timer_timeout() -> void:
	get_next_patrol_pos()

func _on_lose_player_timer_timeout() -> void:
	enter_searching()

func _on_search_timer_timeout() -> void:
	enter_patrolling()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
