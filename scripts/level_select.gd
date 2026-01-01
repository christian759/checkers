extends Control

func _ready():
	# Settings button is now in the UI CanvasLayer
	$UI/SettingsButton.pressed.connect(_on_settings_pressed)
	
	update_level_buttons()
	setup_islands()

func setup_islands():
	# Procedurally place some trees/islands purely for visual flavor
	var island_tex = preload("res://assets/ui/tree_soft.svg")
	for i in range(15):
		var tree = TextureRect.new()
		tree.texture = island_tex
		tree.position = Vector2(randf_range(0, 500), randf_range(0, 2000))
		tree.size = Vector2(80, 80)
		tree.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tree.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		$Background/Islands.add_child(tree)

func update_level_buttons():
	var journey_container = $VBoxContainer/ScrollContainer/Journey
	var levels = []
	for child in journey_container.get_children():
		if child is Button:
			levels.append(child)
	
	var tex_locked = preload("res://assets/ui/level_node_locked.svg")
	var tex_unlocked = preload("res://assets/ui/level_node_unlocked.svg")
	var tex_current = preload("res://assets/ui/level_node_current.svg")
	
	for i in range(levels.size()):
		var level_num = i + 1
		var btn = levels[i]
		
		btn.text = str(level_num)
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.expand_icon = true
		btn.custom_minimum_size = Vector2(120, 120)
		btn.flat = true
		
		# Winding path logic: Zig-zag
		var offset = sin(i * 1.5) * 120.0
		btn.custom_minimum_size.x = 120
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		
		# We can't easily offset in VBox without Container Sizing hacks
		# Better: use a Control wrapper for each button
		
		if not btn.is_connected("pressed", _on_level_selected):
			btn.pressed.connect(func(): _on_level_selected(level_num))
			btn.button_down.connect(func(): _animate_press(btn, true))
			btn.button_up.connect(func(): _animate_press(btn, false))

		if level_num < GameManager.max_unlocked_level:
			btn.icon = tex_unlocked
		elif level_num == GameManager.max_unlocked_level:
			btn.icon = tex_current
		else:
			btn.icon = tex_locked
			btn.disabled = true
			btn.modulate = Color(0.8, 0.8, 0.8)

func _animate_press(btn, down):
	var tween = create_tween()
	if down:
		tween.tween_property(btn, "scale", Vector2(0.9, 0.9), 0.1).set_trans(Tween.TRANS_BACK)
	else:
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_ELASTIC)

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")

func _on_level_selected(level):
	GameManager.reset_game()
	GameManager.current_level = level
	GameManager.current_mode = GameManager.Mode.PV_AI
	SceneTransition.change_scene("res://scenes/main.tscn")
