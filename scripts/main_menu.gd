extends Control

var piece_tex = load("res://assets/textures/piece_player.svg")

func _ready():
	$CenterContainer/VBoxContainer/PlayAI.pressed.connect(_on_play_ai_pressed)
	$CenterContainer/VBoxContainer/PlayFriend.pressed.connect(_on_play_friend_pressed)
	$CenterContainer/VBoxContainer/Levels.pressed.connect(_on_levels_pressed)
	
	spawn_floating_pieces()

func spawn_floating_pieces():
	var container = $FloatingPieces
	for i in range(10):
		var p = TextureRect.new()
		p.texture = piece_tex
		p.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		p.custom_minimum_size = Vector2(64, 64)
		p.size = Vector2(64, 64)
		p.position = Vector2(randf_range(0, 720), randf_range(0, 1280))
		p.modulate = Color(1, 1, 1, 0.2)

		p.set_script(load("res://scripts/floating_piece.gd"))
		p.speed = randf_range(30, 80)
		container.add_child(p)

func _on_play_ai_pressed():
	GameManager.current_mode = GameManager.Mode.PV_AI
	SceneTransition.change_scene("res://scenes/main.tscn")

func _on_play_friend_pressed():
	GameManager.current_mode = GameManager.Mode.PV_P
	SceneTransition.change_scene("res://scenes/main.tscn")

func _on_levels_pressed():
	SceneTransition.change_scene("res://scenes/level_select.tscn")
