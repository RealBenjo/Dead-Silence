extends RayCast2D
class_name VisionCone

signal target_seen(is_seen: bool) ## emits true if any target is seen

@export var VISION_LENGTH := 100.0
@export var target_group: String = "Player"
@export_range(0, 360, 0.1, "degrees") var fov: float = 90.0

var vis_length: float
var vision_multipliers: Array[float]
var is_target_seen := false
var last_state := false 

# --- NEW: Track the actual target node, not just true/false
var last_collider: Node2D = null 

@onready var internal_fov = deg_to_rad(fov / 2.0)

func _ready() -> void:
	if VISION_LENGTH < 1:
		VISION_LENGTH = 100.0
	target_position.x = VISION_LENGTH

func _physics_process(_delta: float) -> void:
	vis_length = VISION_LENGTH
	var closest_target: Node2D = null
	var min_dist: float = INF 
	
	var targets = get_tree().get_nodes_in_group(target_group)
	
	if targets.is_empty():
		_update_state(false, null)
		return
	
	for target in targets:
		if not target is Node2D: continue
		var distance = global_position.distance_to(target.global_position)
		if distance < min_dist:
			min_dist = distance
			closest_target = target
	
	if closest_target:
		_rotate_cone_to_target(closest_target)
	
	for multiplier in vision_multipliers:
		vis_length *= multiplier
	target_position.x = vis_length
	
	force_raycast_update()
	
	var seeing_now = false
	var current_collider: Node2D = null
	
	if is_colliding() and get_collider() == closest_target:
		seeing_now = true
		# --- NEW: Grab the specific node we are looking at right now
		current_collider = get_collider() 
		
	# --- NEW: Pass both the true/false state AND the node we hit
	_update_state(seeing_now, current_collider)

func _rotate_cone_to_target(target: Node2D) -> void:
	# rotate to desired position
	look_at(target.global_position)
	
	if fov >= 360:
		return
	
	# clamps the rotation the the desired range
	rotation = clamp(rotation, -internal_fov, internal_fov)

# --- UPDATED: Fire the signal if the boolean changes OR if the target node switches
func _update_state(new_state: bool, new_collider: Node2D) -> void:
	if new_state != last_state or new_collider != last_collider:
		is_target_seen = new_state
		last_state = new_state
		last_collider = new_collider
		
		# This forces the InteractionNode to run its code and grab the new get_collider()
		target_seen.emit(is_target_seen)
