extends Node2D

@onready var main_ui = $UI/MainUI
@onready var board = $BoardContainer/Board

func _ready():
	GameManager.turn_changed.connect(_on_turn_changed)
	GameManager.game_over.connect(_on_game_over)
	
	setup_ui()

func setup_ui():
	main_ui.get_node("GameOverPopup/Center/VBox/RestartButton").pressed.connect(_on_restart_pressed)
	main_ui.get_node("TopBar/HBox/HomeButton").pressed.connect(_on_home_pressed)

func _on_home_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_turn_changed(new_side):
	var label = main_ui.get_node("TopBar/HBox/TurnIndicator")
	if new_side == GameManager.Side.PLAYER:
		label.text = "YOUR TURN"
		label.add_theme_color_override("font_color", Color("#58cc02"))
	else:
		label.text = "AI THINKING..."
		label.add_theme_color_override("font_color", Color("#ff4b4b"))

func _on_game_over(winner):
	var popup = main_ui.get_node("GameOverPopup")
	var title = popup.get_node("Center/VBox/Title")
	
	popup.show()
	if winner == GameManager.Side.PLAYER:
		title.text = "GREAT JOB!"
		GameManager.win_streak += 1
		GameManager.check_win_condition(winner)
		popup.get_node("Confetti").emitting = true
		AudioManager.play_sound("win")
	else:
		title.text = "NICE TRY!"
		GameManager.win_streak = 0
	
	main_ui.get_node("TopBar/HBox/StreakLabel").text = "🔥 " + str(GameManager.win_streak)

func _on_restart_pressed():
	get_tree().reload_current_scene()
	GameManager.reset_game()
