extends Control

@onready var title_label = $Panel/Title
@onready var next_level_btn = $Panel/HBox/NextLevel

var is_win = false
var next_level_available = false

func setup(winner_side, has_next_level):
	is_win = (winner_side == GameManager.Side.PLAYER)
	next_level_available = has_next_level
	
	if GameManager.current_mode == GameManager.Mode.PV_P:
		if winner_side == GameManager.Side.PLAYER:
			title_label.text = "PLAYER 1 WINS!"
			title_label.modulate = Color(0.2, 0.8, 0.2)
		else:
			title_label.text = "PLAYER 2 WINS!"
			title_label.modulate = Color(0.2, 0.2, 0.8)
		next_level_btn.visible = false
		
	else: # PV_AI
		if is_win:
			title_label.text = "YOU WON!"
			title_label.modulate = Color(0.2, 0.8, 0.2)
			if next_level_available:
				next_level_btn.visible = true
			else:
				next_level_btn.visible = false # Max level reached
		else:
			title_label.text = "YOU LOST!"
			title_label.modulate = Color(0.8, 0.2, 0.2)
			next_level_btn.visible = false
	
	if is_win:
		$Panel/StarContainer.visible = true
		$Panel/ProgressBar.visible = true
	else:
		$Panel/StarContainer.visible = false
		$Panel/ProgressBar.visible = false

func _on_restart_pressed():
	# Restart current scene
	get_tree().reload_current_scene()
	GameManager.reset_game()

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_next_level_pressed():
	if next_level_available:
		GameManager.current_level += 1
		# Reload main scene with new level setup
		get_tree().reload_current_scene()
		GameManager.reset_game()
