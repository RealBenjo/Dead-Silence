@tool
extends Control

# --- Constants ---
const SPRITE_SIZE = Vector2(64, 64)
const OFFSET = Vector2(-32, -32)

# --- Exports ---
@export var bkg_color: Color = Color(0, 0, 0, 0.5):
	set(val): bkg_color = val; queue_redraw()
@export var line_color: Color = Color.WHITE:
	set(val): line_color = val; queue_redraw()
@export var highlight_color: Color = Color(1, 1, 1, 0.3):
	set(val): highlight_color = val; queue_redraw()
@export var outer_radius := 256:
	set(val): outer_radius = val; queue_redraw()
@export var inner_radius := 64:
	set(val): inner_radius = val; queue_redraw()
@export var line_width := 4:
	set(val): line_width = val; queue_redraw()
@export var options: Array[WheelOption]:
	set(val): options = val; queue_redraw()

var selection := 0:
	set(val):
		if selection != val:
			selection = val
			queue_redraw()

# --- Internal Functions ---

func _ready() -> void:
	# Ensure it draws correctly the very first time it's instantiated
	queue_redraw()

func _notification(what: int) -> void:
	# This catches when the node is shown via .show() or .visible = true
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_visible_in_tree():
			selection = 0 # Reset selection to center
			queue_redraw()

func close() -> String:
	hide()
	if options.size() > 0 and selection < options.size():
		return options[selection].name
	return ""

func _draw() -> void:
	var opt_count = options.size()
	if opt_count == 0: 
		return
	
	# background
	draw_circle(Vector2.ZERO, outer_radius, bkg_color)
	
	# highlight
	_draw_highlight(opt_count)
	
	# center icon
	if options[0].atlas:
		draw_texture_rect_region(
			options[0].atlas,
			Rect2(OFFSET, SPRITE_SIZE),
			options[0].region
		)
	
	# 4. Slices and Icons
	if opt_count >= 2:
		var sector_count = opt_count - 1
		var angle_step = TAU / sector_count
		var radius_mid = (inner_radius + outer_radius) / 2.0
		
		for i in range(sector_count):
			var rads = angle_step * i
			var dir = Vector2.from_angle(rads)
			
			# Draw separator lines
			draw_line(dir * inner_radius, dir * outer_radius, line_color, line_width, true)
			
			# Draw Icons
			var mid_rads = (rads + (rads + angle_step)) / 2.0 * -1
			var draw_pos = (radius_mid * Vector2.from_angle(mid_rads)) + OFFSET
			
			var opt_idx = i + 1
			if options[opt_idx].atlas:
				draw_texture_rect_region(
					options[opt_idx].atlas,
					Rect2(draw_pos, SPRITE_SIZE),
					options[opt_idx].region
				)

	# 5. Inner Ring
	draw_arc(Vector2.ZERO, inner_radius, 0, TAU, 128, line_color, line_width, true)

func _draw_highlight(opt_count: int) -> void:
	if selection == 0:
		draw_circle(Vector2.ZERO, inner_radius, highlight_color)
		return
	
	if opt_count < 2: return
	
	var sector_count = opt_count - 1
	var angle_step = TAU / sector_count
	# subtract 1 from selection because index 0 is the center
	var start_rads = (angle_step * (selection - 1))
	var end_rads = (angle_step * selection)
	
	var points_per_arc = 64 # this effects the highlight's poly count
	var points = PackedVector2Array()
	
	for j in range(points_per_arc + 1):
		var angle = start_rads + j * (end_rads - start_rads) / points_per_arc
		points.append(inner_radius * Vector2.from_angle(TAU - angle))
	
	for j in range(points_per_arc, -1, -1): # makes a reversed array, otherwise renders wrong
		var angle = start_rads + j * (end_rads - start_rads) / points_per_arc
		points.append(outer_radius * Vector2.from_angle(TAU - angle))
		
	draw_polygon(points, PackedColorArray([highlight_color]))

func _process(_delta: float) -> void:
	# Only run logic if visible to save CPU
	if not is_visible_in_tree():
		return
		
	var mouse_pos = get_local_mouse_position()
	var mouse_radius = mouse_pos.length()
	
	if mouse_radius < inner_radius:
		selection = 0
	else:
		var opt_count = options.size()
		if opt_count > 1:
			var mouse_rads = fposmod(mouse_pos.angle() * -1, TAU)
			# Standardized math for selection
			var sector_count = opt_count - 1
			var new_selection = floor((mouse_rads / TAU) * sector_count) + 1
			selection = clamp(new_selection, 1, sector_count)
