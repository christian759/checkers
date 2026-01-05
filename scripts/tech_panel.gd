@tool
extends Control

@export var bg_color: Color = Color.WHITE
@export var border_color: Color = Color("#1B4332", 0.1)
@export var border_width: float = 1.0
@export var corner_radius: float = 40.0
@export var show_shadow: bool = true

func _draw():
	var r = Rect2(Vector2.ZERO, size)
	
	# 1. Shadow (Soft Drop)
	if show_shadow:
		var shadow_color = Color(0, 0, 0, 0.03)
		var shadow_offset = 6.0
		var shadow_r = Rect2(Vector2(0, shadow_offset), size)
		draw_style_box_curved(shadow_r, shadow_color, corner_radius)
	
	# 2. Main Body
	draw_style_box_curved(r, bg_color, corner_radius)
	
	# 3. Border
	if border_width > 0:
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color.TRANSPARENT
		sb.set_border_width_all(border_width)
		sb.border_color = border_color
		sb.set_corner_radius_all(corner_radius)
		sb.anti_aliasing = true
		draw_style_box(sb, r)

func draw_style_box_curved(rect: Rect2, color: Color, radius: float):
	var sb = StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(radius)
	sb.anti_aliasing = true
	draw_style_box(sb, rect)

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
