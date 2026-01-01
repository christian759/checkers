extends Control

@onready var container = $Container
@onready var surface = $Container/Surface
@onready var node_container = $Container/Nodes
@onready var path_line = $Container/PathLine

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
	
	# Depth layers
	var sb = surface.get_theme_stylebox("panel", "IslandSurface").duplicate()
	sb.bg_color = island_color
	surface.add_theme_stylebox_override("panel", sb)
	
	var path_points = []
	for i in range(levels.size()):
		var data = levels[i]
		
		# --- STACKED NODE ASSEMBLY ---
		var node_root = Control.new()
		node_root.custom_minimum_size = Vector2(160, 160)
		node_root.pivot_offset = Vector2(80, 80)
		
		# Base (The Rim)
		var base = Panel.new()
		base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		base.theme_type_variation = "NodeBase"
		node_root.add_child(base)
		
		# Top (The Interaction)
		var top = Button.new()
		top.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		top.offset_bottom = -12 # Create the rim gap
		top.theme_type_variation = "NodeTop"
		top.text = str(data.num)
		top.add_theme_font_size_override("font_size", 54)
		top.add_theme_color_override("font_color", Color("#2d5e12", 0.9))
		node_root.add_child(top)
		
		# Pathing (Sine wave)
		var progress = float(i) / (float(levels.size()) - 1.0) if levels.size() > 1 else 0.5
		var ox = sin(progress * PI * 1.5) * 120.0 
		var vertical_step = 160.0
		# Reversed for "Ascent": Level 1 at bottom (large Y), Level 5 at top (small Y)
		var pos = Vector2(250 + ox - 80, 700 - i * vertical_step - 80)
		
		node_root.position = pos
		node_container.add_child(node_root)
		path_points.append(pos + Vector2(80, 80))
		
		top.pressed.connect(func(): _parent_scene._on_level_selected(data.num))
		
		# Progress coloring
		if data.num > GameManager.max_unlocked_level:
			top.disabled = true
			node_root.modulate = Color(1, 1, 1, 0.4)
		
		if data.num < GameManager.max_unlocked_level:
			_add_check_icon(node_root)
		
		if data.num == GameManager.max_unlocked_level:
			_add_current_marker(node_root)

	path_line.points = path_points
	
	# Breathe Animation
	var tween = create_tween().set_loops()
	tween.tween_property(container, "scale", Vector2(1.02, 1.02), 4.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(container, "scale", Vector2(1.0, 1.0), 4.0).set_trans(Tween.TRANS_SINE)

func _add_check_icon(node):
	var check = Label.new()
	check.text = "✓"
	check.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	check.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	check.add_theme_font_size_override("font_size", 44)
	check.add_theme_color_override("font_color", Color("#2d5e12"))
	check.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	check.offset_top = -5
	node.add_child(check)

func _add_current_marker(node):
	var marker_tex = preload("res://assets/ui/marker_blue_bubble.svg")
	var marker = TextureRect.new()
	marker.texture = marker_tex
	marker.size = Vector2(120, 80)
	marker.position = Vector2(-110, 40)
	node.add_child(marker)
	
	var tween = create_tween().set_loops()
	tween.tween_property(marker, "position:y", 30, 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(marker, "position:y", 40, 0.8).set_trans(Tween.TRANS_SINE)
