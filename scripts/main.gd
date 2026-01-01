extends Node2D

@onready var main_ui = $UI/MainUI
@onready var board = $BoardContainer/Board

func _ready():
	GameManager.turn_changed.connect(_on_turn_changed)
	GameManager.game_over.connect(_on_game_over)
	
	setup_ui()
	center_board()

func setup_ui():
	main_ui.get_node("TopBar/HBox/HomeButton").pressed.connect(_on_home_pressed)
	main_ui.get_node("TopBar/HBox/UndoButton").pressed.connect(_on_undo_pressed)

func _on_undo_pressed():
	GameManager.undo()

func _on_home_pressed():
	SceneTransition.change_scene("res://scenes/main_menu.tscn")

func _on_turn_changed(new_side):
	var label = main_ui.get_node("TopBar/HBox/TurnIndicator")
	
	if GameManager.is_daily_challenge:
		label.text = "🌟 DAILY CHALLENGE 🌟"
		label.add_theme_color_override("font_color", Color("#ffcc00"))
		return

	if GameManager.current_mode == GameManager.Mode.PV_AI:
		if new_side == GameManager.Side.AI:
			label.text = "AI THINKING..."
			label.add_theme_color_override("font_color", Color("#ff4b4b"))
		else:
			label.text = "YOUR TURN"
			label.add_theme_color_override("font_color", Color("#58cc02"))
	else: # PvP Mode
		if new_side == GameManager.Side.PLAYER:
			label.text = "PLAYER 1 TURN"
			label.add_theme_color_override("font_color", Color("#58cc02"))
		else:
			label.text = "PLAYER 2 TURN"
			label.add_theme_color_override("font_color", Color("#ff4b4b"))

const GAME_OVER_SCENE = preload("res://scenes/game_over_screen.tscn")

func _on_game_over(winner, next_level_possible):
	var screen = GAME_OVER_SCENE.instantiate()
	$UI.add_child(screen)
	screen.setup(winner, next_level_possible)
	
	if winner == GameManager.Side.PLAYER:
		GameManager.win_streak += 1
		AudioManager.play_sound("win")
	else:
		GameManager.win_streak = 0
	
	main_ui.get_node("TopBar/HBox/StreakLabel").text = "🔥 " + str(GameManager.win_streak)

func _on_restart_pressed():
	get_tree().reload_current_scene()
	GameManager.reset_game()

func center_board():
	# Board size is 8 * 80 = 640
	var board_size = Vector2(640, 640)
	var viewport_size = get_viewport_rect().size
	
	# Center horizontally and vertically
	# Vertical center might need offset for top bar, but pure center is usually fine
	# Given top bar is 80px, maybe we want to center in the remaining space? 
	# For now, let's just true center it on screen, it looks cleanest.
	
	board.position = -board_size / 2
	$BoardContainer.position = viewport_size / 2
