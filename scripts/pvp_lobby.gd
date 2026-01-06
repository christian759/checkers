extends Control

var selected_mode = 0 # 0: AI, 1: Friend
var selected_start_side = 0
var selected_theme_index = 0

func _ready():
	# 1. WIPE PREVIOUS UI (Except Background)
	for child in get_children():
		if child.name != "Background":
			child.queue_free()
	
	# 2. BUILD NEW DASHBOARD LAYOUT
	var main_ui = MarginContainer.new()
	main_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_ui.add_theme_constant_override("margin_left", 40)
	main_ui.add_theme_constant_override("margin_right", 40)
	main_ui.add_theme_constant_override("margin_top", 100)
	main_ui.add_theme_constant_override("margin_bottom", 160)
	add_child(main_ui)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 60)
	main_ui.add_child(vbox)
	
	# HEADER
	var header = Label.new()
	header.text = "MATCH SETUP"
	header.add_theme_font_size_override("font_size", 48)
	header.add_theme_color_override("font_color", GameManager.FOREST)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(header)
	
	# MODE SELECTOR (Modern Pill)
	var mode_pill = _create_pill_selector(["VS AI", "VS FRIEND"], _on_mode_toggled)
	vbox.add_child(mode_pill)
	
	# DASHBOARD SECTION (Split)
	var dashboard = HBoxContainer.new()
	dashboard.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dashboard.add_theme_constant_override("separation", 40)
	vbox.add_child(dashboard)
	
	# LEFT COLUMN: SETTINGS
	var left_col = VBoxContainer.new()
	left_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_col.add_theme_constant_override("separation", 30)
	dashboard.add_child(left_col)
	
	left_col.add_child(_create_section_label("DIFFICULTY"))
	var level_control = _create_difficulty_card()
	left_col.add_child(level_control)
	
	# RIGHT COLUMN: SIDE SELECT
	var right_col = VBoxContainer.new()
	right_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_col.add_theme_constant_override("separation", 30)
	dashboard.add_child(right_col)
	
	right_col.add_child(_create_section_label("SIDE"))
	var side_select = _create_pill_selector(["WHITE", "BLACK"], _on_side_toggled, true)
	right_col.add_child(side_select)
	
	# THEME SECTION
	vbox.add_child(_create_section_label("BOARD THEME"))
	var theme_grid = _create_theme_grid()
	vbox.add_child(theme_grid)
	
	# START ACTION
	var start_btn = Button.new()
	start_btn.text = "START MATCH"
	start_btn.custom_minimum_size = Vector2(0, 100)
	var sb = StyleBoxFlat.new()
	sb.bg_color = GameManager.FOREST
	sb.set_corner_radius_all(100)
	start_btn.add_theme_stylebox_override("normal", sb)
	start_btn.add_theme_stylebox_override("hover", sb)
	start_btn.add_theme_stylebox_override("pressed", sb)
	start_btn.add_theme_color_override("font_color", Color.WHITE)
	start_btn.add_theme_font_size_override("font_size", 28)
	start_btn.pressed.connect(_on_start_pressed)
	vbox.add_child(start_btn)

func _create_section_label(txt):
	var l = Label.new()
	l.text = txt
	l.add_theme_color_override("font_color", GameManager.FOREST.lerp(Color.WHITE, 0.4))
	l.add_theme_font_size_override("font_size", 16)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

var mode_bubble: Panel
var ai_btns = []
func _create_pill_selector(options, callback, _vertical = false):
	var pill = Panel.new()
	pill.custom_minimum_size = Vector2(0, 70)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color.WHITE
	sb.set_corner_radius_all(100)
	sb.set_border_width_all(2)
	sb.border_color = GameManager.BORDER_SOFT
	pill.add_theme_stylebox_override("panel", sb)
	
	var bubble = Panel.new()
	var b_sb = StyleBoxFlat.new()
	b_sb.bg_color = GameManager.FOREST
	b_sb.set_corner_radius_all(100)
	bubble.add_theme_stylebox_override("panel", b_sb)
	bubble.size = Vector2(180, 58) # Initial size, refined in callback
	bubble.position = Vector2(6, 6)
	pill.add_child(bubble)
	
	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pill.add_child(hbox)
	
	for i in range(options.size()):
		var btn = Button.new()
		btn.text = options[i]
		btn.flat = true
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 18)
		btn.pressed.connect(callback.bind(i, btn, bubble))
		hbox.add_child(btn)
		if i == 0:
			btn.add_theme_color_override("font_color", Color.WHITE)
		else:
			btn.add_theme_color_override("font_color", GameManager.FOREST)
	
	return pill

func _on_mode_toggled(index, btn, bubble):
	selected_mode = index
	var target_x: float = float(btn.position.x + 6)
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(bubble, "position:x", target_x, 0.4)
	tween.tween_property(bubble, "size:x", float(btn.size.x - 12), 0.4)
	
	for b in btn.get_parent().get_children():
		b.add_theme_color_override("font_color", Color.WHITE if b == btn else GameManager.FOREST)

func _on_side_toggled(index, btn, bubble):
	selected_start_side = index
	var target_x: float = float(btn.position.x + 6)
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(bubble, "position:x", target_x, 0.4)
	tween.tween_property(bubble, "size:x", float(btn.size.x - 12), 0.4)
	
	for b in btn.get_parent().get_children():
		b.add_theme_color_override("font_color", Color.WHITE if b == btn else GameManager.FOREST)

var level_val_label: Label
var current_ai_level = 100
func _create_difficulty_card():
	var card = Panel.new()
	card.custom_minimum_size = Vector2(0, 160)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color.WHITE
	sb.set_corner_radius_all(GameManager.MEDIUM_RADIUS)
	sb.set_border_width_all(2)
	sb.border_color = GameManager.BORDER_SOFT
	card.add_theme_stylebox_override("panel", sb)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("margin_left", 20)
	vbox.add_theme_constant_override("margin_right", 20)
	card.add_child(vbox)
	
	level_val_label = Label.new()
	level_val_label.text = "100"
	level_val_label.add_theme_font_size_override("font_size", 48)
	level_val_label.add_theme_color_override("font_color", GameManager.FOREST)
	level_val_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(level_val_label)
	
	var slider = HSlider.new()
	slider.min_value = 1
	slider.max_value = 200
	slider.value = 100
	slider.value_changed.connect(func(v):
		current_ai_level = v
		level_val_label.text = str(int(v))
	)
	vbox.add_child(slider)
	
	return card

func _create_theme_grid():
	var grid = HBoxContainer.new()
	grid.alignment = HORIZONTAL_ALIGNMENT_CENTER
	grid.add_theme_constant_override("separation", 20)
	
	for i in range(GameManager.BOARD_THEMES.size()):
		var t = GameManager.BOARD_THEMES[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(80, 80)
		btn.flat = true
		
		var icon = Panel.new()
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var sb = StyleBoxFlat.new()
		sb.bg_color = t.dark
		sb.set_corner_radius_all(24)
		sb.set_border_width_all(4)
		sb.border_color = Color.WHITE
		icon.add_theme_stylebox_override("panel", sb)
		btn.add_child(icon)
		
		btn.pressed.connect(func(): _on_theme_select(i, icon, grid))
		grid.add_child(btn)
		
		if i == selected_theme_index:
			sb.border_color = GameManager.MINT_SAGE
			btn.scale = Vector2(1.1, 1.1)
			
	return grid

func _on_theme_select(idx, _icon, grid):
	selected_theme_index = idx
	for child in grid.get_children():
		var node = child.get_child(0)
		var sb = node.get_theme_stylebox("panel")
		var is_sel = (child.get_index() == idx)
		sb.border_color = GameManager.MINT_SAGE if is_sel else Color.WHITE
		child.scale = Vector2(1.1, 1.1) if is_sel else Vector2(1.0, 1.0)

func _on_start_pressed():
	var mode = GameManager.Mode.PV_AI if selected_mode == 0 else GameManager.Mode.PV_P
	var side = GameManager.Side.PLAYER if selected_start_side == 0 else GameManager.Side.AI
	GameManager.start_custom_game(mode, int(current_ai_level), selected_theme_index, side)
