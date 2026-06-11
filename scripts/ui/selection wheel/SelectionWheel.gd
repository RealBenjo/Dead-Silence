@tool
extends Control
class_name SelectionWheel

const SPRITE_SIZE = Vector2(64, 64)
const OFFSET = Vector2(-32, -32)

signal option_selected(option: WheelOption)

@export_group("Visuals")
@export var segments: int = 4
@export var bkg_color: Color = Color(0, 0, 0, 0.5)
@export var line_color: Color = Color.WHITE
@export var highlight_color: Color = Color(1, 1, 1, 0.3)

@export_group("Dimensions")
@export var outer_radius := 256.0
@export var inner_radius := 64.0
@export var line_width := 4.0

@export_group("Options")
@export var options: Array[WheelOption]

var selection := 1
var stored_mouse_pos := Vector2.ZERO
var used_mouse_to_open := true

func _ready() -> void:
	stored_mouse_pos = get_viewport().get_mouse_position()
	close()

func open(is_mouse: bool) -> void:
	used_mouse_to_open = is_mouse
	show()
	selection = 0
	if Engine.is_editor_hint(): return
	
	if used_mouse_to_open:
		stored_mouse_pos = get_viewport().get_mouse_position()
		get_viewport().warp_mouse(get_viewport_rect().size / 2.0)

func close() -> void:
	if not Engine.is_editor_hint() and used_mouse_to_open:
		get_viewport().warp_mouse(stored_mouse_pos)
	hide()
	
	if options.size() > 0 and selection < options.size():
		option_selected.emit(options[selection])

func _process(_delta: float) -> void:
	# brute-force redraw every frame.
	queue_redraw()
	
	if Engine.is_editor_hint() or not is_visible_in_tree() or options.size() <= 1: return
	
	var joy_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	var mouse_pos = get_local_mouse_position()
	
	# Priority 1: Controller Input
	# 0.2 is just safety deadzone
	if joy_dir.length() > 0.2:
		selection = _get_selection_from_angle(joy_dir.angle())
		
	# Priority 2: Mouse Input (Only checks if we opened the wheel with the mouse!)
	elif used_mouse_to_open and mouse_pos.length() > inner_radius:
		selection = _get_selection_from_angle(mouse_pos.angle())
	else:
		selection = 0

# depending on the angle it gets the index of the selected item 
func _get_selection_from_angle(angle: float) -> int:
	var sector_count = options.size() - 1
	var input_rads = fposmod(angle, TAU)
	
	# get percentually where the angle is according to the circle
	# multiply that percentage with the sector count,
	# get rid of the decimal and add 1 as 0 is the middle item index
	return int( (input_rads / TAU) * sector_count ) + 1

# --- THE MATH FIX ---
func _get_poly_radius(angle: float, base_radius: float) -> float:
	if segments < 3: return base_radius
	
	var segment_angle = TAU / float(segments)
	var half_seg = segment_angle / 2.0
	var local_angle = fposmod(angle, segment_angle) - half_seg
	
	return base_radius * cos(half_seg) / cos(local_angle)

# --- DRAWING ---
func _draw() -> void:
	# safety check for options Array
	if options.size() == 0: return
	
	# 1. Background Polygon
	_draw_poly_circle(outer_radius, bkg_color)
	
	# 2. Highlight
	if selection == 0:
		_draw_poly_circle(inner_radius, highlight_color)
	else:
		_draw_sector_highlight()
	
	# 3. Center Icon (UPDATED to handle both Texture types)
	if options[0] and options[0].icon:
		draw_texture_rect(options[0].icon, Rect2(OFFSET, SPRITE_SIZE), false)
	
	# 4. Slices & Icons (UPDATED to handle both Texture types)
	var sector_count = options.size() - 1
	if sector_count > 0:
		var angle_step = TAU / sector_count
		for i in range(sector_count):
			var rads = angle_step * i
			
			var r_in = _get_poly_radius(rads, inner_radius)
			var r_out = _get_poly_radius(rads, outer_radius)
			draw_line(Vector2.from_angle(rads) * r_in, Vector2.from_angle(rads) * r_out, line_color, line_width)
			
			var mid_rads = rads + (angle_step / 2.0)
			var mid_r = (_get_poly_radius(mid_rads, inner_radius) + _get_poly_radius(mid_rads, outer_radius)) / 2.0
			var draw_pos = (mid_r * Vector2.from_angle(mid_rads)) + OFFSET
			
			# Check the texture type for the slices
			# Fallback for standard images (.png)
			if options[i+1] and options[i+1].icon:
				draw_texture_rect(options[i+1].icon, Rect2(draw_pos, SPRITE_SIZE), false)
	
	# 5. Inner Ring 
	var inner_pts = PackedVector2Array()
	for i in range(segments + 1):
		inner_pts.append(Vector2.from_angle((TAU / segments) * i) * inner_radius)
	draw_polyline(inner_pts, line_color, line_width, true)

func _draw_poly_circle(radius: float, color: Color) -> void:
	var pts = PackedVector2Array()
	for i in range(segments):
		pts.append(Vector2.from_angle((TAU / segments) * i) * radius)
	draw_polygon(pts, PackedColorArray([color]))

func _draw_sector_highlight() -> void:
	var sector_count = options.size() - 1
	var angle_step = TAU / sector_count
	var start_rads = angle_step * (selection - 1)
	var end_rads = angle_step * selection
	
	var resolution = 32
	var pts = PackedVector2Array()
	
	# this gets the OUTER perimeter points of the wheel
	# and saves those into the pts PackedVector2Array
	for idx in range(resolution + 1):
		var a = start_rads + idx * (end_rads - start_rads) / resolution
		pts.append(Vector2.from_angle(a) * _get_poly_radius(a, outer_radius))
	
	# this gets the INNER perimeter points of the wheel
	# and saves those into the pts PackedVector2Array
	for idx in range(resolution, -1, -1):
		var a = start_rads + idx * (end_rads - start_rads) / resolution
		pts.append(Vector2.from_angle(a) * _get_poly_radius(a, inner_radius))
		
	draw_polygon(pts, PackedColorArray([highlight_color]))
