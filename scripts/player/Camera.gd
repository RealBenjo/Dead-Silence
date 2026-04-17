extends Camera2D

@export var max_distance := 200.0
@export var controller_speed := 1000.0
@export var mouse_sensitivity := 0.3

# We add a hidden counter to track skipped frames
var _frames_to_skip := 0

# Turn this into a setter so it reacts the exact moment it changes
var is_wheel_open := false:
	set(val):
		# If it WAS open, and is NOW closing...
		if is_wheel_open == true and val == false:
			_frames_to_skip = 2 # Give the OS 2 frames to update the mouse warp
		is_wheel_open = val

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		Globals.is_using_mouse = true
	elif event is InputEventJoypadMotion or event is InputEventJoypadButton:
		if event is InputEventJoypadMotion and abs(event.axis_value) < 0.2:
			return
		Globals.is_using_mouse = false

func _process(delta: float) -> void:
	# 1. Freeze if the wheel is open
	if is_wheel_open:
		return
		
	# 2. Freeze for an extra 2 frames immediately after closing to hide the mouse warp lag
	if _frames_to_skip > 0:
		_frames_to_skip -= 1
		return
	
	if Globals.is_using_mouse:
		var parent_pos = get_parent().global_position
		var mouse_pos = get_global_mouse_position()
		var target = (mouse_pos - parent_pos) * mouse_sensitivity
		offset = target.limit_length(max_distance)
	else:
		var joy_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
		if joy_dir != Vector2.ZERO:
			offset += joy_dir * controller_speed * delta
			offset = offset.limit_length(max_distance)
