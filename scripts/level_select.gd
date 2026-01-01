var selected_node_num = 1

func _ready():
	$UI/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/ScrollContainer.get_v_scroll_bar().value_changed.connect(_on_scroll)
	
	generate_levels()
	update_level_buttons()
	setup_islands()
	update_season_display(0)

func _on_daily_pressed():
	GameManager.reset_game()
	GameManager.is_daily_challenge = true
	GameManager.current_mode = GameManager.Mode.PV_AI
	SceneTransition.change_scene("res://scenes/main.tscn")

func _on_pvp_pressed():
	# Quick friend match (Level 1 as base)
	GameManager.reset_game()
	GameManager.current_mode = GameManager.Mode.PV_P
	SceneTransition.change_scene("res://scenes/main.tscn")

func _on_level_selected(level):
	selected_node_num = level
	$ModeSelect/Panel/VBox/Title.text = "LEVEL " + str(level)
	$ModeSelect.visible = true

func _on_mode_selected(mode_idx):
	$ModeSelect.visible = false
	GameManager.reset_game()
	GameManager.current_level = selected_node_num
	GameManager.current_mode = GameManager.Mode.PV_AI if mode_idx == 0 else GameManager.Mode.PV_P
	SceneTransition.change_scene("res://scenes/main.tscn")

func _on_close_mode_select():
	$ModeSelect.visible = false
