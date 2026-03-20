@tool
extends Control


@export var bkg_color: Color
@export var outer_radious := 256
#@export var outer_radious := 256


func _draw() -> void:
	draw_circle(Vector2.ZERO, outer_radious, bkg_color)

func _process(delta: float) -> void:
	queue_redraw()
