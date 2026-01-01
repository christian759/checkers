extends Control

const TOTAL_LEVELS = 80
const LEVELS_PER_SEASON = 20

func _ready():
	$UI/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/ScrollContainer.get_v_scroll_bar().value_changed.connect(_on_scroll)
	
	generate_levels()
	update_level_buttons()
	setup_islands()
	update_season_display(0)

func generate_levels():
	var journey = $VBoxContainer/ScrollContainer/Journey
	# Remove Level1 reference if it exists to avoid dupes
	if journey.has_node("Level1"):
		journey.get_node("Level1").queue_free()
	
	for i in range(TOTAL_LEVELS):
		var btn = Button.new()
		btn.name = "Level" + str(i + 1)
		btn.custom_minimum_size = Vector2(140, 140)
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.flat = true
		btn.text = str(i + 1)
		btn.add_theme_font_size_override("font_size", 32)
		btn.pivot_offset = Vector2(70, 70)
		journey.add_child(btn)

func _on_scroll(value):
	# Estimate current season based on scroll value
	var max_scroll = $VBoxContainer/ScrollContainer.get_v_scroll_bar().max_value
	if max_scroll > 0:
		var progress = value / max_scroll
		var season_index = clamp(int(progress * 4), 0, 3)
		update_season_display(season_index)

func update_season_display(idx):
	var seasons = [
		{"name": "SPRING", "color": Color("#3fd15b"), "icon": preload("res://assets/ui/icon_spring.svg")},
		{"name": "SUMMER", "color": Color("#f5e050"), "icon": preload("res://assets/ui/icon_summer.svg")},
		{"name": "AUTUMN", "color": Color("#e08031"), "icon": preload("res://assets/ui/icon_autumn.svg")},
		{"name": "WINTER", "color": Color("#7ec9f5"), "icon": preload("res://assets/ui/icon_winter.svg")}
	]
	
	var s = seasons[idx]
	$VBoxContainer/SeasonHeader/HBox/Title.text = "SEASON " + str(idx + 1) + ": " + s.name
	$VBoxContainer/SeasonHeader/HBox/Icon.texture = s.icon
	
	# Transition background water color
	var tween = create_tween()
	tween.tween_property($Background/Water, "color", s.color.lerp(Color.WHITE, 0.2), 0.5)

func update_level_buttons():
	var journey_container = $VBoxContainer/ScrollContainer/Journey
	var levels = journey_container.get_children().filter(func(c): return c is Button)
	
	var tex_locked = preload("res://assets/ui/level_node_locked.svg")
	var tex_unlocked = preload("res://assets/ui/level_node_unlocked.svg")
	var tex_current = preload("res://assets/ui/level_node_current.svg")
	
	for i in range(levels.size()):
		var level_num = i + 1
		var btn = levels[i]
		
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.expand_icon = true
		
		# Winding path logic: Zig-zag
		# Shift X based on sine wave but keep size fixed
		# Since it's in a VBox, we use a spacer or margin?
		# Better: use a dummy Control as parent for each button to allow absolute X offset
		
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
