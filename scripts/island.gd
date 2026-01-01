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
		
		# Organic winding path logic
		# Screenshot shows (38, 39, 40) winding UP
		var step_y = 120
		var ox = 0
		if i % 4 == 1: ox = 80
		elif i % 4 == 3: ox = -80
		
		btn.position = Vector2(250 + ox - 80, 500 - i * step_y - 80)
		node_container.add_child(btn)
		
		# Connect signals
		btn.pressed.connect(func(): _parent_scene._on_level_selected(data.num))
		
		# Custom Visuals (Circle nodes)
		_apply_node_style(btn, data.num)
		
		# Add Markers
		if data.has("boss"):
			_add_boss_marker(btn, data.boss)
		
		if data.num == GameManager.max_unlocked_level:
			_add_current_marker(btn)

func _apply_node_style(btn, num):
	var tex_locked = preload("res://assets/ui/level_node_locked.svg")
	var tex_unlocked = preload("res://assets/ui/level_node_unlocked.svg")
	var tex_current = preload("res://assets/ui/level_node_current.svg")
	
	btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.expand_icon = true
	
	# Font styling
	btn.add_theme_font_size_override("font_size", 48)
	btn.add_theme_color_override("font_color", Color("#4a4a4a"))
	
	if num < GameManager.max_unlocked_level:
		btn.icon = tex_unlocked
	elif num == GameManager.max_unlocked_level:
		btn.icon = tex_current
	else:
		btn.icon = tex_locked
		btn.disabled = true
		btn.modulate = Color(0.8, 0.8, 0.8)

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
	
	# Animate float
	var tween = create_tween().set_loops()
	tween.tween_property(marker, "position:x", -110.0, 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(marker, "position:x", -100.0, 0.8).set_trans(Tween.TRANS_SINE)
