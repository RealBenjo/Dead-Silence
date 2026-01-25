extends CharacterBody2D
class_name EnemyWalking


# node vars
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var vision: RayCast2D = $Vision
@onready var lose_player_timer: Timer = $Timers/LosePlayerTimer
@onready var stop_search_timer: Timer = $Timers/StopSearchTimer
@onready var investigate_timer: Timer = $Timers/InvestigationTimer
@onready var search_timer: Timer = $Timers/SearchTimer
@onready var patrol_timer: Timer = $Timers/PatrolTimer

# basic functionality vars
@export var speed: float = 100.0
@export var health: int = 100
@export var damage: int = 10
var can_attack: bool = false

# vision vars
@export_range(0, 360, 0.1, "degrees") var fov: float = 90.0
@export var default_vision_length: int = 500
var vision_length: Vector2 = Vector2.RIGHT * default_vision_length
var vision_mult: float = 1.0
var state_vision_mult: float = 1.0

# awareness vars
@export var max_awareness: float = 300.0
var awareness: float = 0.0
var awareness_mult: float = 1.0
var player_velocity: float = 0.0

# state vars
enum state {PATROLLING, INVESTIGATING, SEARCHING, ATTACKING}
var current_state: state = state.PATROLLING
var player_seen: bool = false
var sound_heard: bool = false

# pathfinding vars
var interest_pos: Vector2
var sound_position: Vector2

# patrol vars
@export var patrol_time_min: float = 10.0
@export var patrol_time_max: float = 30.0
var patrol: Array
var patrol_index: int = 0

# player vars
var player_speed_mult: float = 1.0 ##it is clamped between 1.0 - 2.0


func _ready() -> void:
	# the nav agent REALLY needs to know the max_speed for avoidance!
	nav.max_speed = speed
	
	get_next_patrol_pos()
	patrol_timer.wait_time = randf_range(patrol_time_min, patrol_time_max)


func _physics_process(_delta):
	update_vision_length(vision_mult, state_vision_mult)
	update_vision_cone()
	handle_vision()
	update_awareness()
	state_machine()
	
	#print(patrol_timer.time_left)
	#print(search_timer.time_left)
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



# --- VISION HANDLING ---
func handle_vision() -> void:
	if vision.is_colliding():
		var collider = vision.get_collider()
		if collider.is_in_group("Player"):
			player_seen = true
		else:
			player_seen = false
	else:
		player_seen = false


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

func update_vision_length(new_vision_mult: float, new_state_mult: float) -> void:
	vision_length = Vector2.RIGHT * default_vision_length * new_vision_mult * new_state_mult
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
		interest_pos = sound_position
		enter_investigating()
		return
	
	check_awareness()
	
	if nav.is_navigation_finished() and patrol_timer.is_stopped():
		patrol_timer.start()


func process_investigating() -> void:
	check_sound()
	check_awareness()
	
	make_path(interest_pos)
	
	if nav.is_navigation_finished() and investigate_timer.is_stopped():
		investigate_timer.start()


func process_searching() -> void:
	if check_sound():
		search_timer.stop()
	check_awareness()
	
	if nav.is_navigation_finished() and search_timer.is_stopped():
		search_timer.start()


func process_attacking() -> void:
	check_sound()
	
	if player_seen:
		lose_player_timer.stop()
		interest_pos = Globals.player_pos
		
		if can_attack:
			# TODO: play an animation, at a certain frame of the animation, the player takes big damage or something
			Globals.health -= damage
			print("attack")
		
	elif lose_player_timer.is_stopped():
		lose_player_timer.start()
	
	make_path(interest_pos)



# --- STATE ENTER ---
# all of these only run once when called
func enter_patrolling() -> void:
	current_state = state.PATROLLING
	state_vision_mult = 1.0

##enemy will investigate the given position
func enter_investigating() -> void:
	current_state = state.INVESTIGATING
	state_vision_mult = 1.1

func enter_searching() -> void:
	current_state = state.SEARCHING
	stop_search_timer.start()
	state_vision_mult = 1.2

func enter_attacking() -> void:
	current_state = state.ATTACKING
	lose_player_timer.start()
	state_vision_mult = 10.0



# --- AUX ---
##if an enemy is more aware than a certain max_awareness percentage, it will enter the appropriate state
func check_awareness() -> void:
	if awareness >= max_awareness and current_state != state.ATTACKING:
		#TODO: implement slow-mo when getting detected by an enemy
		#Engine.time_scale = 0.1
		enter_attacking()
		
	elif awareness > max_awareness * 0.5:
		# if an enemy sees a player for more than 50% awareness they will know the player's exact position
		interest_pos = Globals.player_pos
		if current_state == state.PATROLLING:
			enter_investigating()

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

func _on_investigation_timer_timeout() -> void:
	enter_patrolling()

func _on_lose_player_timer_timeout() -> void:
	enter_searching()

func _on_stop_search_timer_timeout() -> void:
	enter_patrolling()

func _on_search_timer_timeout() -> void:
	interest_pos = vector_offset(global_position, 500)
	make_path(interest_pos)

# very important so enemies try to avoid each other and not just run into each other
func _on_nav_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		can_attack = true

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		can_attack = false
