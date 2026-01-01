extends Control

@onready var container = $Container
@onready var node_container = $Container/Surface/Nodes

var _parent_scene = null

func setup(_season_idx, levels, main_scene):
	_parent_scene = main_scene
	
	# Clear existing
	for child in node_container.get_children():
		child.queue_free()
	
	for i in range(levels.size()):
		var data = levels[i]
		
		# --- PREMIUM NODE ASSEMBLY (High Fidelity) ---
		var node_root = Control.new()
		node_root.custom_minimum_size = Vector2(170, 170)
		node_root.pivot_offset = Vector2(85, 85)
		
		# Base (Rim/Depth)
		var base = Panel.new()
		base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		base.theme_type_variation = "NodePremiumBase"
		node_root.add_child(base)
		
		# Top (Surface)
		var top = Button.new()
		top.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		top.offset_bottom = -16 # Premium thickness
		top.theme_type_variation = "NodePremiumTop"
		top.text = str(data.num)
		top.add_theme_font_size_override("font_size", 58)
		top.add_theme_color_override("font_color", Color("#404040"))
		node_root.add_child(top)
		
		# Prototypical Sine Placement (Better Padding)
		var progress = float(i) / (float(levels.size()) - 1.0) if levels.size() > 1 else 0.5
		var ox = sin(progress * PI * 1.5) * 140.0 
		var pos = Vector2(270 + ox - 85, 750 - i * 170 - 85)
		
		node_root.position = pos
		node_container.add_child(node_root)
		
		top.pressed.connect(func(): _parent_scene._on_level_selected(data.num))
		
		# Unlock Logic
		if data.num > GameManager.max_unlocked_level:
			top.disabled = true
			node_root.modulate = Color(1, 1, 1, 0.4)
		
		if data.num < GameManager.max_unlocked_level:
			_add_completion_mark(node_root)
		
		if data.num == GameManager.max_unlocked_level:
			_add_current_indicator(node_root)

	_animate_island()

func _animate_island():
	# Subtle floating sway
	var tween = create_tween().set_loops().set_parallel(true)
	tween.tween_property(container, "position:y", 10.0, 4.0).set_trans(Tween.TRANS_SINE).as_relative()
	tween.tween_property(container, "position:y", -10.0, 4.0).set_trans(Tween.TRANS_SINE).set_delay(4.0).as_relative()
	
	# Subtle breath scale
	var st = create_tween().set_loops()
	st.tween_property(container, "scale", Vector2(1.01, 1.01), 5.0).set_trans(Tween.TRANS_SINE)
	st.tween_property(container, "scale", Vector2(1.0, 1.0), 5.0).set_trans(Tween.TRANS_SINE)

func _add_completion_mark(node):
	var mark = Label.new()
	mark.text = "✓"
	mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mark.add_theme_font_size_override("font_size", 48)
	mark.add_theme_color_override("font_color", Color("#58cc02"))
	mark.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mark.offset_top = -10
	node.add_child(mark)

func _add_current_indicator(node):
	var marker_tex = preload("res://assets/ui/marker_blue_bubble.svg")
	var marker = TextureRect.new()
	marker.texture = marker_tex
	marker.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	marker.size = Vector2(100, 70)
	marker.position = Vector2(-115, 30)
	node.add_child(marker)
	
	var tween = create_tween().set_loops()
	tween.tween_property(marker, "position:x", -125, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(marker, "position:x", -115, 0.6).set_trans(Tween.TRANS_SINE)
