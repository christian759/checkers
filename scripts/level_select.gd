extends Control

const TOTAL_LEVELS = 80
const LEVELS_PER_SEASON = 20
var selected_node_num = 1

@onready var mastery_card_scene = preload("res://scenes/mastery_card.tscn")



@onready var journey = $ScrollContainer/Journey
@onready var scroll_container = $ScrollContainer

func _ready():
	_setup_navigation()
	generate_levels()
	update_season_display(0)

func _setup_navigation():
	$BottomNav/HBox/Achievements.pressed.connect(func(): SceneTransition.change_scene("res://scenes/achievements_menu.tscn"))
	$BottomNav/HBox/Daily.pressed.connect(_on_daily_pressed)
	$BottomNav/HBox/Mastery.pressed.connect(_on_pvp_pressed)
	$BottomNav/HBox/Settings.pressed.connect(_on_settings_pressed)
	
	# Peak button logic - Scroll to top
	var peak_panel = $BottomNav/Peak
	var hidden_btn = Button.new()
	hidden_btn.flat = true
	hidden_btn.layout_mode = 1
	hidden_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	peak_panel.add_child(hidden_btn)
	hidden_btn.pressed.connect(func(): scroll_container.scroll_vertical = 0)

func generate_levels():
	for child in journey.get_children():
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
			if level_num % 10 == 0: data["boss"] = "skull"
			if level_num % 20 == 0: data["boss"] = "crown"
			levels_data.append(data)
		
		var season_idx = clamp(int(float(i * 5) / LEVELS_PER_SEASON), 0, 3)
		island.setup(season_idx, levels_data, self)

func update_level_buttons():
	# Refresh all islands to reflect progress
	generate_levels() 

func _on_scroll(_value):
	pass # Progress-based season updates disabled for now

func update_season_display(_idx):
	# Season header removed in new UI layout
	pass



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
