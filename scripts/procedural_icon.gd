extends Control

func _draw():
	var category = get_meta("category") if has_meta("category") else "skill"
	var is_unlocked = get_meta("unlocked") if has_meta("unlocked") else false
	
	var color = _get_category_color(category)
	if not is_unlocked:
		color = Color("#BDC3C7") # Crisp Silver/Gray
	
	var center = size / 2.0
	var radius = min(size.x, size.y) / 2.0 - 4.0
	
	# Draw Solid Outline (Professional Style)
	draw_circle(center, radius, Color.WHITE)
	draw_circle(center, radius, Color("#27AE60") if is_unlocked else Color("#95A5A6"), false, 2.0)
	
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
		"progression": return Color("#F1C40F") # Solid Gold
		"combat": return Color("#E74C3C") # Solid Red
		"skill": return Color("#3498DB") # Solid Blue
		"style": return Color("#9B59B6") # Solid Purple
		_: return Color("#2ECC71") # Solid Green

func _draw_star(center, radius, color):
	var points = PackedVector2Array()
	for i in range(10):
		var angle = deg_to_rad(i * 36 - 90)
		var r = radius if i % 2 == 0 else radius * 0.45
		points.append(center + Vector2(cos(angle), sin(angle)) * r)
	draw_colored_polygon(points, color)
	draw_polyline(points, color.darkened(0.2), 1.5)

func _draw_sword(center, radius, color):
	var points = PackedVector2Array([
		center + Vector2(0, -radius),
		center + Vector2(radius * 0.25, 0),
		center + Vector2(0, radius),
		center + Vector2(-radius * 0.25, 0)
	])
	draw_colored_polygon(points, color)
	draw_rect(Rect2(center.x - radius * 0.4, center.y - 2, radius * 0.8, 4), color.darkened(0.3))

func _draw_shield(center, radius, color):
	var points = PackedVector2Array([
		center + Vector2(-radius * 0.8, -radius * 0.6),
		center + Vector2(radius * 0.8, -radius * 0.6),
		center + Vector2(radius * 0.8, radius * 0.3),
		center + Vector2(0, radius),
		center + Vector2(-radius * 0.8, radius * 0.3)
	])
	draw_colored_polygon(points, color)
	draw_polyline(points, color.darkened(0.2), 1.5)

func _draw_diamond(center, radius, color):
	var points = PackedVector2Array([
		center + Vector2(0, -radius),
		center + Vector2(radius * 0.9, 0),
		center + Vector2(0, radius),
		center + Vector2(-radius * 0.9, 0)
	])
	draw_colored_polygon(points, color)
	draw_polyline(points, color.darkened(0.2), 1.5)
