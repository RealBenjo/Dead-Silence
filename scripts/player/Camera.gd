extends Camera2D

@export var max_distance := 200.0
@export var controller_speed := 1000.0 # How fast the stick moves the camera
@export var mouse_sensitivity := 0.3

var is_using_mouse := true

func _input(event: InputEvent) -> void:
	# 1. Detect device swap seamlessly
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		is_using_mouse = true
	elif event is InputEventJoypadMotion or event is InputEventJoypadButton:
		# Ignore tiny stick drifts so it doesn't accidentally steal control from the mouse
		if event is InputEventJoypadMotion and abs(event.axis_value) < 0.2:
			return
		is_using_mouse = false

func _process(delta: float) -> void:
	if is_using_mouse:
		# --- MOUSE LOGIC ---
		# Get parent's global_position (the exact center of the player)
		var parent_pos = get_parent().global_position
		var mouse_pos = get_global_mouse_position()
		
		# Calculate offset and scale it down
		var target_offset = (mouse_pos - parent_pos) * mouse_sensitivity
		
		# limit_length() automatically clamps the vector without needing distance checks!
		offset = target_offset.limit_length(max_distance)
		
	else:
		# --- CONTROLLER LOGIC ---
		var joy_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
		
		# Only move if the stick is actually being pushed
		if joy_dir != Vector2.ZERO:
			offset += joy_dir * controller_speed * delta
			
			# Clamp it so the controller can't push it past the max distance
			offset = offset.limit_length(max_distance)
