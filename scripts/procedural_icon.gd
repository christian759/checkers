extends Control

func _draw():
	var category = get_meta("category") if has_meta("category") else "skill"
	var is_unlocked = get_meta("unlocked") if has_meta("unlocked") else false
	
	var color = _get_category_color(category)
	if not is_unlocked:
		color = Color("#DAE3DF") # Soft Grayed Mint
	
	var center = size / 2.0
	var radius = min(size.x, size.y) / 2.0 - 5.0
	
	# Draw Base Circle
	draw_circle(center, radius, Color.WHITE)
	draw_circle(center, radius, color.lightened(0.8), false, 2.0)
	
	# Draw Inner Shape (No thick outlines)
	match category:
		"progression":
			_draw_star(center, radius * 0.65, color)
		"combat":
			_draw_sword(center, radius * 0.65, color)
		"skill":
			_draw_shield(center, radius * 0.65, color)
		"style":
			_draw_diamond(center, radius * 0.65, color)
		_:
			draw_circle(center, radius * 0.5, color)

func _get_category_color(cat):
	match cat:
		"progression": return Color("#2ECC71") # Mint Green
		"combat": return Color("#FF7675") # Coral Rose
		"skill": return Color("#74B9FF") # Sky Blue
		"style": return Color("#A29BFE") # Lavender
		_: return Color("#55E6C1") # Teal

func _draw_star(center, radius, color):
	var points = PackedVector2Array()
	for i in range(10):
		var angle = deg_to_rad(i * 36 - 90)
		var r = radius if i % 2 == 0 else radius * 0.45
		points.append(center + Vector2(cos(angle), sin(angle)) * r)
	draw_colored_polygon(points, color)

func _draw_sword(center, radius, color):
	var points = PackedVector2Array([
		center + Vector2(0, -radius),
		center + Vector2(radius * 0.25, 0),
		center + Vector2(0, radius),
		center + Vector2(-radius * 0.25, 0)
	])
	draw_colored_polygon(points, color)
	# Soft Guard
	draw_rect(Rect2(center.x - radius * 0.35, center.y - 2, radius * 0.7, 4), color.darkened(0.2))

func _draw_shield(center, radius, color):
	var points = PackedVector2Array([
		center + Vector2(-radius * 0.8, -radius * 0.5),
		center + Vector2(radius * 0.8, -radius * 0.5),
		center + Vector2(radius * 0.8, radius * 0.3),
		center + Vector2(0, radius),
		center + Vector2(-radius * 0.8, radius * 0.3)
	])
	draw_colored_polygon(points, color)

func _draw_diamond(center, radius, color):
	var points = PackedVector2Array([
		center + Vector2(0, -radius),
		center + Vector2(radius * 0.9, 0),
		center + Vector2(0, radius),
		center + Vector2(-radius * 0.9, 0)
	])
	draw_colored_polygon(points, color)
