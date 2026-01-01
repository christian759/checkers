extends Control

const TOTAL_LEVELS = 80
const LEVELS_PER_SEASON = 20
var selected_node_num = 1

@onready var mastery_card_scene = preload("res://scenes/mastery_card.tscn")
@onready var journey = $ScrollContainer/Journey
@onready var scroll_container = $ScrollContainer

func _ready():
	_setup_navigation()
	_setup_overlays()
	generate_levels()
	update_season_display(0)
	
	# Start at Level 1 (Bottom of ScrollContainer)
	await get_tree().process_frame
	scroll_container.scroll_vertical = 999999

func _setup_navigation():
	# Pentagonal Bar Slots
	$BottomNav/HBox/PvP.pressed.connect(func(): _start_match(GameManager.Mode.PV_P))
	$BottomNav/HBox/AI.pressed.connect(func(): show_ai_journey())
	$BottomNav/HBox/Mastery.pressed.connect(func(): SceneTransition.change_scene("res://scenes/achievements_menu.tscn"))
	$BottomNav/HBox/Daily.pressed.connect(_on_daily_pressed)
	
	# Peak button logic - Scroll to current/base
	var peak_panel = $BottomNav/PeakSystem/Core
	var hidden_btn = Button.new()
	hidden_btn.flat = true
	hidden_btn.layout_mode = 1
	hidden_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	peak_panel.add_child(hidden_btn)
	hidden_btn.pressed.connect(func(): scroll_container.scroll_vertical = 999999)

func _setup_overlays():
	# ModeSelect Signals
	$ModeSelect/Panel/VBox/PvAI.pressed.connect(func(): _on_mode_selected(0))
	$ModeSelect/Panel/VBox/PvP.pressed.connect(func(): _on_mode_selected(1))
	
	# Close logic (Clicking overlay background)
	var close_btn = Button.new()
	close_btn.flat = true
	close_btn.layout_mode = 1
	close_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$ModeSelect.add_child(close_btn)
	$ModeSelect.move_child(close_btn, 0)
	close_btn.pressed.connect(func(): $ModeSelect.visible = false)
	
	var close_journey = Button.new()
	close_journey.flat = true
	close_journey.layout_mode = 1
	close_journey.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$AIJourney.add_child(close_journey)
	$AIJourney.move_child(close_journey, 0)
	close_journey.pressed.connect(func(): $AIJourney.visible = false)

func generate_levels():
	for child in journey.get_children():
		child.queue_free()
	
	var island_scene = preload("res://scenes/island.tscn")
	
	for i in range(16): 
		var island = island_scene.instantiate()
		journey.add_child(island)
		journey.move_child(island, 0) # Newer levels go on TOP (stacking up)
		
		var levels_data = []
		for j in range(5):
			var level_num = i * 5 + j + 1
			var data = {"num": level_num}
			if level_num % 10 == 0: data["boss"] = "skull"
			if level_num % 20 == 0: data["boss"] = "crown"
			levels_data.append(data)
		
		var season_idx = clamp(int(float(i * 5) / LEVELS_PER_SEASON), 0, 3)
		island.setup(season_idx, levels_data, self)

func update_season_display(_idx):
	pass

# --- Mode & AI Journey ---

func _on_level_selected(level):
	selected_node_num = level
	var title_node = $ModeSelect/Panel/VBox/Title
	if title_node:
		title_node.text = "LEVEL " + str(level)
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
	
	for child in cards_container.get_children():
		child.queue_free()
	
	for i in range(1, 16):
		var card = mastery_card_scene.instantiate()
		cards_container.add_child(card)
		card.setup(i, {})
		card.level_pressed.connect(_on_ai_level_pressed)

func _on_ai_level_pressed(num):
	selected_node_num = num
	_start_match(GameManager.Mode.PV_AI)

func _start_match(mode):
	GameManager.reset_game()
	GameManager.current_level = selected_node_num
	GameManager.current_mode = mode
	SceneTransition.change_scene("res://scenes/main.tscn")

func _on_daily_pressed():
	GameManager.reset_game()
	GameManager.is_daily_challenge = true
	GameManager.current_mode = GameManager.Mode.PV_AI
	SceneTransition.change_scene("res://scenes/main.tscn")
