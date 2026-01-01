extends Control

func _ready():
	_update_ui()

func _update_ui():
	# Update button states based on GameManager settings
	$Panel/VBoxContainer/ForcedJumps/Button.text = "ON" if GameManager.forced_jumps else "OFF"
	$Panel/VBoxContainer/MovementMode/Button.text = "DIAGONAL" if GameManager.movement_mode == "diagonal" else "STRAIGHT"
	$Panel/VBoxContainer/BoardTheme/Button.text = GameManager.get_current_board_theme().name

func _on_back_pressed():
	# Go back to Main Menu / Map
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_forced_jumps_pressed():
	GameManager.forced_jumps = !GameManager.forced_jumps
	_update_ui()
	GameManager.save_game()

func _on_movement_mode_pressed():
	if GameManager.movement_mode == "diagonal":
		GameManager.movement_mode = "straight"
	else:
		GameManager.movement_mode = "diagonal"
	_update_ui()
	GameManager.save_game()

func _on_board_theme_pressed():
	GameManager.cycle_board_theme()
	_update_ui()
