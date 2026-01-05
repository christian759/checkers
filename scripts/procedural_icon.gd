extends Control

func _draw():
	var category = get_meta("category") if has_meta("category") else "skill"
	var is_unlocked = get_meta("unlocked") if has_meta("unlocked") else false
	
	var color = _get_category_color(category)
	if not is_unlocked:
		color = color.lerp(Color.GRAY, 0.7)
	
	var center = size / 2.0
	var radius = min(size.x, size.y) / 2.0 - 5.0
	
	# Draw Shadow/Outline First (Brutal Style)
	draw_circle(center + Vector2(4, 4), radius, Color.BLACK)
	draw_circle(center, radius, Color.WHITE)
	draw_circle(center, radius, Color.BLACK, false, 4.0)
	
	# Draw Inner Shape
	match category:
		"progression":
			_draw_star(center, radius * 0.7, color)
		"combat":
			_draw_sword(center, radius * 0.7, color)
		"skill":
			_draw_shield(center, radius * 0.7, color)
		"style":
			_draw_diamond(center, radius * 0.7, color)
		_:
			draw_circle(center, radius * 0.5, color)

func _get_category_color(cat):
	match cat:
		"progression": return Color("#f1c40f") # Gold
		"combat": return Color("#e74c3c") # Red
		"skill": return Color("#3498db") # Blue
		"style": return Color("#9b59b6") # Purple
		_: return Color("#2ecc71") # Green

func _draw_star(center, radius, color):
	var points = PackedVector2Array()
	for i in range(10):
		var angle = deg_to_rad(i * 36 - 90)
		var r = radius if i % 2 == 0 else radius * 0.4
		points.append(center + Vector2(cos(angle), sin(angle)) * r)
	draw_colored_polygon(points, color)
	draw_polyline(points, Color.BLACK, 2.0)

func _draw_sword(center, radius, color):
	# Simple cross shape for sword
	var points = PackedVector2Array([
		center + Vector2(0, -radius),
		center + Vector2(radius * 0.2, 0),
		center + Vector2(0, radius),
		center + Vector2(-radius * 0.2, 0)
	])
	draw_colored_polygon(points, color)
	# Guard
	draw_line(center + Vector2(-radius * 0.4, 0), center + Vector2(radius * 0.4, 0), Color.BLACK, 4.0)

func _draw_shield(center, radius, color):
	var points = PackedVector2Array([
		center + Vector2(-radius, -radius * 0.5),
		center + Vector2(radius, -radius * 0.5),
		center + Vector2(radius, radius * 0.3),
		center + Vector2(0, radius),
		center + Vector2(-radius, radius * 0.3)
	])
	draw_colored_polygon(points, color)
	draw_polyline(points, Color.BLACK, 2.0)

func _draw_diamond(center, radius, color):
	var points = PackedVector2Array([
		center + Vector2(0, -radius),
		center + Vector2(radius, 0),
		center + Vector2(0, radius),
		center + Vector2(-radius, 0)
	])
	draw_colored_polygon(points, color)
	draw_polyline(points, Color.BLACK, 2.0)
