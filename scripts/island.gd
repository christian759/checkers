extends Control

@onready var surface = $Surface
@onready var node_container = $Surface/Nodes

var _parent_scene = null

func setup(season_idx, levels, main_scene):
	_parent_scene = main_scene
	
	# Match screenshot colors
	var colors = [
		Color("#8ec442"), # Spring (Green)
		Color("#f9a03f"), # Autumn (Orange/Tan)
		Color("#f5e050"), # Summer (Yellow)
		Color("#ffffff")  # Winter (White)
	]
	surface.modulate = colors[season_idx % colors.size()]
	
	for i in range(levels.size()):
		var data = levels[i]
		var btn = Button.new()
		btn.name = "Level" + str(data.num)
		btn.text = str(data.num)
		btn.custom_minimum_size = Vector2(160, 160)
		btn.flat = true
		btn.pivot_offset = Vector2(80, 80)
		
		# Refined "Snake" Pathing - Perfectly Center-Balanced
		var progress = float(i) / (float(levels.size()) - 1.0) if levels.size() > 1 else 0.5
		var ox = sin(progress * PI * 1.5) * 160.0 # Winding range
		var vertical_step = 180.0
		
		btn.position = Vector2(360 + ox - 80, 800 - i * vertical_step - 80)
		node_container.add_child(btn)
		
		# Connect signals
		btn.pressed.connect(func(): _parent_scene._on_level_selected(data.num))
		
		# Custom Visuals
		_apply_node_style(btn, data.num)
		
		if data.num < GameManager.max_unlocked_level:
			_add_check_icon(btn)
		
		# Add Markers
		if data.has("boss"):
			_add_boss_marker(btn, data.boss)
		
		if data.num == GameManager.max_unlocked_level:
			_add_current_marker(btn)
			
	_add_foliage()

func _add_foliage():
	var tree_tex = preload("res://assets/ui/tree_premium.svg")
	for i in range(8):
		var tree = TextureRect.new()
		tree.texture = tree_tex
		var rand_pos = Vector2(randf_range(50, 450), randf_range(50, 550))
		tree.position = rand_pos
		var s = randf_range(0.6, 1.2)
		tree.scale = Vector2(s, s)
		tree.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tree.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		node_container.add_child(tree)
		node_container.move_child(tree, 0) # Trees behind buttons

func _apply_node_style(btn, num):
	btn.flat = false # We need the stylebox visible
	
	var sb_normal = StyleBoxFlat.new()
	sb_normal.set_corner_radius_all(80) # Perfect circle
	sb_normal.bg_color = Color("#8ec442")
	sb_normal.border_width_bottom = 8 # Rim effect
	sb_normal.border_color = Color("#549b0e")
	sb_normal.content_margin_top = 10
	
	var sb_hover = sb_normal.duplicate()
	sb_hover.bg_color = Color("#9ed452")
	
	var sb_pressed = sb_normal.duplicate()
	sb_pressed.bg_color = Color("#7cb335")
	sb_pressed.border_width_bottom = 2 # Pressed in look
	
	btn.add_theme_stylebox_override("normal", sb_normal)
	btn.add_theme_stylebox_override("hover", sb_hover)
	btn.add_theme_stylebox_override("pressed", sb_pressed)
	
	# Clean Typography matching goal
	btn.add_theme_font_size_override("font_size", 54)
	btn.add_theme_color_override("font_color", Color("#2d5e12", 0.8)) # Soft dark green-grey
	
	if num > GameManager.max_unlocked_level:
		btn.disabled = true
		sb_normal.bg_color = Color("#cccccc")
		sb_normal.border_color = Color("#aaaaaa")

func _add_check_icon(btn):
	# Create a native Godot icon (e.g., a simple Label with a "✓")
	# Or a simple checkmark drawn with Line2D for that clean look
	var check = Label.new()
	check.text = "✓"
	check.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	check.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	check.add_theme_font_size_override("font_size", 40)
	check.add_theme_color_override("font_color", Color("#2d5e12"))
	check.size = Vector2(80, 80)
	check.position = Vector2(40, 40)
	btn.add_child(check)

func _add_boss_marker(btn, type):
	var skull_tex = preload("res://assets/ui/boss_skull.svg")
	var crown_tex = preload("res://assets/textures/crown.svg")
	var marker = TextureRect.new()
	marker.texture = crown_tex if type == "crown" else skull_tex
	marker.size = Vector2(60, 60)
	marker.position = Vector2(100, 100)
	btn.add_child(marker)

func _add_current_marker(btn):
	var marker_tex = preload("res://assets/ui/marker_blue_bubble.svg")
	var marker = TextureRect.new()
	marker.texture = marker_tex
	marker.size = Vector2(120, 80)
	marker.position = Vector2(-100, 40) # Position bubble to the left of node
	btn.add_child(marker)
	
	# Premium "Breathe & Float" Animation
	var tween = create_tween().set_loops()
	tween.tween_property(marker, "position:x", -110.0, 1.2).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(marker, "scale", Vector2(1.05, 1.05), 1.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(marker, "position:x", -100.0, 1.2).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(marker, "scale", Vector2(1.0, 1.0), 1.2).set_trans(Tween.TRANS_SINE)
	
	# Animate the island itself for "Ocean Flow"
	var island_tween = create_tween().set_loops()
	island_tween.tween_property(surface, "scale", Vector2(1.02, 1.02), 3.0).set_trans(Tween.TRANS_SINE)
	island_tween.tween_property(surface, "scale", Vector2(1.0, 1.0), 3.0).set_trans(Tween.TRANS_SINE)
	
	# Shoreline Ripple Pulse
	# The SVG has ripples in it, so we pulse their visibility/modulate
	var ripple_tween = create_tween().set_loops()
	ripple_tween.tween_property(surface, "modulate", Color(1.1, 1.1, 1.1, 1.0), 2.0).set_trans(Tween.TRANS_SINE)
	ripple_tween.tween_property(surface, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0).set_trans(Tween.TRANS_SINE)
