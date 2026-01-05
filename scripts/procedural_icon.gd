extends Control

@export var category: String = "general"
@export var color: Color = Color("#1B4332") # Forest Green
@export var line_width: float = 3.0

func _draw():
	var center = size / 2
	var radius = min(size.x, size.y) * 0.35
	
	var draw_category = category
	if has_meta("category"):
		draw_category = get_meta("category")
	
	var draw_color = color
	if has_meta("accent_color"):
		draw_color = get_meta("accent_color")
	
	# Clean Minimalist Shapes
	match draw_category:
		"win":
			# Trophy Cup
			var pts = PackedVector2Array([
				center + Vector2(-radius, -radius * 0.5),
				center + Vector2(radius, -radius * 0.5),
				center + Vector2(radius * 0.5, radius * 0.5),
				center + Vector2(-radius * 0.5, radius * 0.5)
			])
			draw_polyline(pts, draw_color, line_width, true)
		"capture":
			# Simple Target Circle
			draw_arc(center, radius, 0, TAU, 32, draw_color, line_width)
			draw_circle(center, radius * 0.2, draw_color)
		"king":
			# Simple 3-point Crown
			var pts = PackedVector2Array([
				center + Vector2(-radius, radius * 0.5),
				center + Vector2(radius, radius * 0.5),
				center + Vector2(radius, -radius * 0.2),
				center + Vector2(radius * 0.5, radius * 0.2),
				center + Vector2(0, -radius * 0.5),
				center + Vector2(-radius * 0.5, radius * 0.2),
				center + Vector2(-radius, -radius * 0.2)
			])
			draw_polyline(pts, draw_color, line_width, true)
		"streak":
			# Simple Flame/Drop
			draw_arc(center, radius, PI / 4, PI * 1.75, 32, draw_color, line_width)
		"daily":
			# Simple Star
			var pts = PackedVector2Array()
			for i in range(11):
				var r = radius * (1.1 if i % 2 == 0 else 0.5)
				var angle = deg_to_rad(i * 36 - 90)
				pts.append(center + Vector2(cos(angle), sin(angle)) * r)
			draw_polyline(pts, draw_color, line_width, true)
		_:
			draw_circle(center, radius * 0.8, draw_color)
