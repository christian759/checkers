extends Control

const TOTAL_LEVELS = 80
const LEVELS_PER_SEASON = 20
var selected_node_num = 1

@onready var mastery_card_scene = preload("res://scenes/mastery_card.tscn")

func _ready():
	# Connect UI elements
	$UI/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/ScrollContainer.get_v_scroll_bar().value_changed.connect(_on_scroll)
	
	# Initial Setup
	generate_levels()
	update_level_buttons()
	setup_islands()
	update_season_display(0)

# --- Vertical Map & Seasons ---

func generate_levels():
	var journey = $VBoxContainer/ScrollContainer/Journey
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
		btn.pressed.connect(func(): _on_level_selected(i + 1))
		btn.button_down.connect(func(): _animate_press(btn, true))
		btn.button_up.connect(func(): _animate_press(btn, false))
		journey.add_child(btn)

func update_level_buttons():
	var journey_container = $VBoxContainer/ScrollContainer/Journey
	var buttons = journey_container.get_children().filter(func(c): return c is Button)
	
	var tex_locked = preload("res://assets/ui/level_node_locked.svg")
	var tex_unlocked = preload("res://assets/ui/level_node_unlocked.svg")
	var tex_current = preload("res://assets/ui/level_node_current.svg")
	
	for i in range(buttons.size()):
		var level_num = i + 1
		var btn = buttons[i]
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.expand_icon = true
		
		if level_num < GameManager.max_unlocked_level:
			btn.icon = tex_unlocked
		elif level_num == GameManager.max_unlocked_level:
			btn.icon = tex_current
		else:
			btn.icon = tex_locked
			btn.disabled = true
			btn.modulate = Color(0.8, 0.8, 0.8)

func _on_scroll(value):
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
	
	var water = $Background/Water
	var tween = create_tween()
	tween.tween_property(water, "color", s.color.lerp(Color.WHITE, 0.2), 0.5)

func setup_islands():
	var island_tex = preload("res://assets/ui/tree_soft.svg")
	for i in range(15):
		var tree = TextureRect.new()
		tree.texture = island_tex
		tree.position = Vector2(randf_range(0, 500), randf_range(0, 2000))
		tree.size = Vector2(80, 80)
		tree.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tree.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		$Background/Islands.add_child(tree)

# --- Mode & AI Journey ---

func _on_level_selected(level):
	selected_node_num = level
	$ModeSelect/Panel/VBox/Title.text = "LEVEL " + str(level)
	$ModeSelect.visible = true

func _on_mode_selected(mode_idx):
	$ModeSelect.visible = false
	if mode_idx == 0: # PLAY VS AI (Launch Journey)
		show_ai_journey()
	else: # PLAY WITH FRIEND (Direct Launch)
		_start_match(GameManager.Mode.PV_P)

func show_ai_journey():
	$AIJourney.visible = true
	var cards_container = $AIJourney/VBox/ScrollWrap/ScrollContainer/Cards
	
	# Clear previous cards (between padding)
	for child in cards_container.get_children():
		if not child.name.begins_with("Spacer"):
			child.queue_free()
	
	for i in range(1, 16):
		var card = mastery_card_scene.instantiate()
		cards_container.add_child(card)
		cards_container.move_child(card, cards_container.get_child_count() - 2) # Keep SpacerEnd at end
		card.setup(i, {}) # {} for future mastery data
		card.level_pressed.connect(_on_ai_level_pressed)

func _on_ai_level_pressed(num):
	selected_node_num = num # The AI journey level
	_start_match(GameManager.Mode.PV_AI)

func _start_match(mode):
	GameManager.reset_game()
	GameManager.current_level = selected_node_num
	GameManager.current_mode = mode
	SceneTransition.change_scene("res://scenes/main.tscn")

# --- UI Signals ---

func _on_daily_pressed():
	GameManager.reset_game()
	GameManager.is_daily_challenge = true
	GameManager.current_mode = GameManager.Mode.PV_AI
	SceneTransition.change_scene("res://scenes/main.tscn")

func _on_pvp_pressed():
	_start_match(GameManager.Mode.PV_P)

func _on_close_mode_select():
	$ModeSelect.visible = false

func _on_close_ai_journey():
	$AIJourney.visible = false

func _on_settings_pressed():
	SceneTransition.change_scene("res://scenes/settings_menu.tscn")

func _animate_press(btn, down):
	var tween = create_tween()
	if down:
		tween.tween_property(btn, "scale", Vector2(0.9, 0.9), 0.1).set_trans(Tween.TRANS_BACK)
	else:
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_ELASTIC)
