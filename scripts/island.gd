extends Control

@onready var surface = $Surface
@onready var node_container = $Surface/Nodes

var _parent_scene = null

func setup(season_idx, levels, main_scene):
	_parent_scene = main_scene
	
	var colors = [
		Color("#8ec442"), # Spring
		Color("#f9a03f"), # Autumn
		Color("#f5e050"), # Summer
		Color("#ffffff")  # Winter
	]
	var island_color = colors[season_idx % colors.size()]
	
	# Clean native styling
	var sb = surface.get_theme_stylebox("panel").duplicate()
	sb.bg_color = island_color
	surface.add_theme_stylebox_override("panel", sb)
	
	# High-Rim circular nodes
	for i in range(levels.size()):
		var data = levels[i]
		var btn = Button.new()
		btn.name = "Level" + str(data.num)
		btn.text = str(data.num)
		btn.custom_minimum_size = Vector2(180, 180)
		btn.pivot_offset = Vector2(90, 90)
		
		# Pro "Snake" Pathing
		var progress = float(i) / (float(levels.size()) - 1.0) if levels.size() > 1 else 0.5
		var ox = sin(progress * PI * 1.5) * 140.0 
		var vertical_step = 180.0
		
		btn.position = Vector2(250 + ox - 90, 750 - i * vertical_step - 90)
		node_container.add_child(btn)
		
		btn.pressed.connect(func(): _parent_scene._on_level_selected(data.num))
		
		_apply_node_style(btn, data.num)
		
		if data.num < GameManager.max_unlocked_level:
			_add_check_icon(btn)
		
		if data.num == GameManager.max_unlocked_level:
			_add_current_marker(btn)
	
	# Breathe Animation for Island (Single Tween)
	var tween = create_tween().set_loops()
	tween.tween_property(surface, "position:y", surface.position.y - 15, 3.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(surface, "position:y", surface.position.y + 15, 3.0).set_trans(Tween.TRANS_SINE)

func _apply_node_style(btn, num):
	btn.add_theme_font_size_override("font_size", 54)
	btn.add_theme_color_override("font_color", Color("#2d5e12", 0.9))
	
	if num > GameManager.max_unlocked_level:
		btn.disabled = true
		btn.modulate = Color(1, 1, 1, 0.4)

func _add_check_icon(btn):
	var check = Label.new()
	check.text = "✓"
	check.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	check.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	check.add_theme_font_size_override("font_size", 44)
	check.add_theme_color_override("font_color", Color("#2d5e12"))
	check.size = Vector2(160, 160)
	check.position = Vector2(0, 0)
	btn.add_child(check)

func _add_current_marker(btn):
	var marker_tex = preload("res://assets/ui/marker_blue_bubble.svg")
	var marker = TextureRect.new()
	marker.texture = marker_tex
	marker.size = Vector2(120, 80)
	marker.position = Vector2(-100, 40)
	btn.add_child(marker)
	
	var tween = create_tween().set_loops()
	tween.tween_property(marker, "position:y", 30, 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(marker, "position:y", 40, 0.8).set_trans(Tween.TRANS_SINE)
