extends Control

func _ready():
	$CenterContainer/VBoxContainer/PlayAI.pressed.connect(_on_play_ai_pressed)
	$CenterContainer/VBoxContainer/PlayFriend.pressed.connect(_on_play_friend_pressed)
	$CenterContainer/VBoxContainer/Levels.pressed.connect(_on_levels_pressed)

func _on_play_ai_pressed():
	GameManager.current_mode = GameManager.Mode.PV_AI
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_play_friend_pressed():
	GameManager.current_mode = GameManager.Mode.PV_P
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_levels_pressed():
	# Placeholder for now, or go to level select
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")
