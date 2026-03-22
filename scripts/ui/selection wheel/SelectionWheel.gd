@tool
extends Control

const SPRITE_SIZE = Vector2(64, 64)
const OFFSET = Vector2(-32, -32)

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

var selection := 0
var stored_mouse_pos := Vector2.ZERO
var used_mouse_to_open := true

func open(is_mouse: bool) -> void:
	used_mouse_to_open = is_mouse
	show()
	selection = 0
	if Engine.is_editor_hint(): return
	
	if used_mouse_to_open:
		stored_mouse_pos = get_viewport().get_mouse_position()
		var center = get_viewport_rect().size / 2.0
		get_viewport().warp_mouse(center)

func close() -> String:
	if not Engine.is_editor_hint() and used_mouse_to_open:
		get_viewport().warp_mouse(stored_mouse_pos)
	hide()
	return options[selection].name if selection < options.size() else ""

func _process(_delta: float) -> void:
	# Brute-force redraw every frame. 
	queue_redraw()
	
	if Engine.is_editor_hint() or not is_visible_in_tree(): return
	
	var joy_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	var mouse_pos = get_local_mouse_position()
	var opt_count = options.size()
	if opt_count <= 1: return
	
	# Priority 1: Controller Input
	if joy_dir.length() > 0.2:
		var sector_count = opt_count - 1
		var input_rads = fposmod(joy_dir.angle(), TAU)
		selection = int(floor((input_rads / TAU) * sector_count)) + 1
		
	# Priority 2: Mouse Input (Only checks if we opened the wheel with the mouse!)
	elif used_mouse_to_open:
		if mouse_pos.length() > inner_radius:
			var sector_count = opt_count - 1
			var input_rads = fposmod(mouse_pos.angle(), TAU)
			selection = int(floor((input_rads / TAU) * sector_count)) + 1
		else:
			selection = 0

# --- THE MATH FIX ---
func _get_poly_radius(angle: float, base_radius: float) -> float:
	if segments < 3: return base_radius
	var segment_angle = TAU / float(segments)
	var half_seg = segment_angle / 2.0
	var wrapped = fposmod(angle, segment_angle)
	var local_angle = wrapped - half_seg
	return base_radius * cos(half_seg) / cos(local_angle)

# --- DRAWING ---
func _draw() -> void:
	if options.size() == 0: return
	
	# 1. Background Polygon
	_draw_poly_circle(outer_radius, bkg_color)
	
	# 2. Highlight
	if selection == 0:
		_draw_poly_circle(inner_radius, highlight_color)
	else:
		_draw_sector_highlight()
	
	# 3. Center Icon
	if options[0].atlas:
		draw_texture_rect_region(options[0].atlas, Rect2(OFFSET, SPRITE_SIZE), options[0].region)
	
	# 4. Slices & Icons
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
			if options[i+1].atlas:
				draw_texture_rect_region(options[i+1].atlas, Rect2(draw_pos, SPRITE_SIZE), options[i+1].region)

	# 5. Inner Ring 
	var inner_pts = PackedVector2Array()
	for i in range(segments + 1):
		var a = (TAU / segments) * i
		inner_pts.append(Vector2.from_angle(a) * inner_radius)
	draw_polyline(inner_pts, line_color, line_width, true)

func _draw_poly_circle(radius: float, color: Color) -> void:
	var pts = PackedVector2Array()
	for i in range(segments):
		var a = (TAU / segments) * i
		pts.append(Vector2.from_angle(a) * radius)
	draw_polygon(pts, PackedColorArray([color]))

func _draw_sector_highlight() -> void:
	var sector_count = options.size() - 1
	var angle_step = TAU / sector_count
	var s_rads = angle_step * (selection - 1)
	var e_rads = angle_step * selection
	
	var res = 32 
	var pts = PackedVector2Array()
	
	for j in range(res + 1):
		var a = s_rads + j * (e_rads - s_rads) / res
		pts.append(Vector2.from_angle(a) * _get_poly_radius(a, outer_radius))
		
	for j in range(res, -1, -1):
		var a = s_rads + j * (e_rads - s_rads) / res
		pts.append(Vector2.from_angle(a) * _get_poly_radius(a, inner_radius))
		
	draw_polygon(pts, PackedColorArray([highlight_color]))
