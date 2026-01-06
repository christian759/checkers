@tool
extends Control

@export var bg_color: Color = Color.WHITE
@export var border_color: Color = Color("#1B4332", 0.08)
@export var border_width: float = 1.5
@export var corner_radius: float = 48.0 # Larger default for "organic" feel
@export var show_shadow: bool = true

func _draw():
	var r = Rect2(Vector2.ZERO, size)
	
	# 1. Shadow (Ultra Soft Elevation)
	if show_shadow:
		var shadow_color = Color(0, 0, 0, 0.02)
		for i in range(3):
			var shadow_offset = 4.0 + i * 4.0
			var shadow_r = Rect2(Vector2(0, shadow_offset), size)
			var sb = StyleBoxFlat.new()
			sb.bg_color = shadow_color
			sb.set_corner_radius_all(corner_radius + i * 2)
			sb.anti_aliasing = true
			draw_style_box(sb, shadow_r)
	
	# 2. Main Body (Pure White / Mint)
	var sb_main = StyleBoxFlat.new()
	sb_main.bg_color = bg_color
	sb_main.set_corner_radius_all(corner_radius)
	sb_main.anti_aliasing = true
	
	# 3. Soft Border
	if border_width > 0:
		sb_main.set_border_width_all(border_width)
		sb_main.border_color = border_color
	
	draw_style_box(sb_main, r)

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
