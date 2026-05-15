extends RayCast2D
class_name VisionCone

signal target_seen(is_seen: bool)

@export var VISION_LENGTH := 100.0
@export var target_group: String = "Player"
@export_range(0, 360, 0.1, "degrees") var fov: float = 90.0

var vis_length: float
var vision_multipliers: Array[float]
var is_target_seen := false
var last_state := false 

@onready var internal_fov = deg_to_rad(fov / 2.0)

func _ready() -> void:
	if VISION_LENGTH < 1:
		VISION_LENGTH = 100.0
	target_position.x = VISION_LENGTH

func _physics_process(_delta: float) -> void:
	# reset variables
	vis_length = VISION_LENGTH
	var closest_target: Node2D = null
	
	# CRITICAL: start with INF so we can find targets outside the current ray length
	var min_dist: float = INF 
	
	# find all potential targets
	var targets = get_tree().get_nodes_in_group(target_group)
	
	if targets.is_empty():
		_update_state(false)
		return
	
	# find the closest target
	for target in targets:
		if not target is Node2D: continue
		var distance = global_position.distance_to(target.global_position)
		if distance < min_dist:
			min_dist = distance
			closest_target = target
	
	# rotate the cone to face the target if it exists
	if closest_target:
		_rotate_cone_to_target(closest_target)
	
	# handle multipliers if there even are any
	for multiplier in vision_multipliers:
		vis_length *= multiplier
	target_position.x = vis_length
	
	# We see it if: we are colliding AND the collider is the target AND it's within range
	var seeing_now = false
	if is_colliding() and get_collider() == closest_target and min_dist <= vis_length:
		seeing_now = true
		
	_update_state(seeing_now)

func _rotate_cone_to_target(target: Node2D) -> void:
	var angle_to_target = (target.global_position - global_position).angle()
	
	# Get the relative angle based on the parent's rotation
	var parent_rot = get_parent().global_rotation
	var relative_angle = wrapf(angle_to_target - parent_rot, -PI, PI)
	
	# Clamp to FOV
	relative_angle = clamp(relative_angle, -internal_fov, internal_fov)
	
	# Apply to local rotation
	rotation = relative_angle

func _update_state(new_state: bool) -> void:
	is_target_seen = new_state
	if is_target_seen != last_state:
		target_seen.emit(is_target_seen)
		last_state = is_target_seen
