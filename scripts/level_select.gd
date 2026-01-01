extends Control

const TOTAL_LEVELS = 80
const LEVELS_PER_SEASON = 20
var selected_node_num = 1

@onready var mastery_card_scene = preload("res://scenes/mastery_card.tscn")

func _ready():
	# Connect UI elements
	$UI/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/ScrollContainer.get_v_scroll_bar().value_changed.connect(_on_scroll)
	
	# Connect Bottom Bar signals
	$BottomBar/HBox/Social/Btn.pressed.connect(_on_pvp_pressed)
	$BottomBar/HBox/Daily/Btn.pressed.connect(_on_daily_pressed)
	$BottomBar/HBox/TourTab/VBox/Tour.pressed.connect(func(): $VBoxContainer/ScrollContainer.scroll_vertical = 0)
	$BottomBar/HBox/Settings/Btn.pressed.connect(_on_settings_pressed)
	
	# Initial Setup
	generate_levels()
	setup_islands()
	update_season_display(0)
	var journey = $VBoxContainer/ScrollContainer/Journey
	for child in journey.get_children():
		if child.name != "Padding":
			child.queue_free()
	
	var island_scene = preload("res://scenes/island.tscn")
	
	for i in range(16): # 80 levels / 5 per island = 16 islands
		var island = island_scene.instantiate()
		journey.add_child(island)
		
		# Prepare level data for this island
		var levels_data = []
		for j in range(5):
			var level_num = i * 5 + j + 1
			var data = {"num": level_num}
			if level_num % 20 == 0: data["boss"] = "crown"
			elif level_num % 10 == 0: data["boss"] = "skull"
			levels_data.append(data)
		
		var season_idx = clamp(int((i * 5) / LEVELS_PER_SEASON), 0, 3)
		island.setup(season_idx, levels_data, self)

func update_level_buttons():
	# Now handled via the Island component's setup, 
	# but we can refresh all islands if needed
	generate_levels() 

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
