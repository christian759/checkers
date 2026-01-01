extends Control

@onready var surface = $Surface
@onready var node_container = $Surface/Nodes

func setup(season_idx, levels):
	var colors = [
		Color("#8ec442"), # Spring
		Color("#f5e050"), # Summer
		Color("#e08031"), # Autumn
		Color("#ffffff")  # Winter
	]
	surface.modulate = colors[season_idx]
	
	for i in range(levels.size()):
		var data = levels[i]
		var btn = Button.new()
		btn.name = "Level" + str(data.num)
		btn.text = str(data.num)
		btn.custom_minimum_size = Vector2(140, 140)
		btn.flat = true
		btn.pivot_offset = Vector2(70, 70)
		
		# Position in zig-zag
		var ox = 0 if i % 2 == 0 else 100
		if i % 4 >= 2: ox = -ox # More complex winding
		
		btn.position = Vector2(200 + ox - 70, 100 + i * 180 - 70)
		node_container.add_child(btn)
		
		# Connect signals
		btn.pressed.connect(func(): owner._on_level_selected(data.num))
		
		# Set icon based on state
		_update_button_visual(btn, data.num)
		
		# Add specific markers
		if data.has("boss"):
			_add_boss_marker(btn, data.boss)
		
		if data.num == GameManager.max_unlocked_level:
			_add_current_marker(btn)

func _update_button_visual(btn, num):
	var tex_locked = preload("res://assets/ui/level_node_locked.svg")
	var tex_unlocked = preload("res://assets/ui/level_node_unlocked.svg")
	var tex_current = preload("res://assets/ui/level_node_current.svg")
	
	btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn.expand_icon = true
	
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
	marker.size = Vector2(50, 50)
	marker.position = Vector2(90, 90)
	btn.add_child(marker)

func _add_current_marker(btn):
	var marker_tex = preload("res://assets/ui/marker_cup_bubble.svg")
	var marker = TextureRect.new()
	marker.texture = marker_tex
	marker.size = Vector2(100, 100)
	marker.position = Vector2(-20, -80)
	btn.add_child(marker)
	
	# Animate float
	var tween = create_tween().set_loops()
	tween.tween_property(marker, "position:y", -90.0, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(marker, "position:y", -80.0, 1.0).set_trans(Tween.TRANS_SINE)
