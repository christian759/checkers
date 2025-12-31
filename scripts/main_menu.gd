extends Control

var piece_tex = load("res://assets/textures/piece_player.svg")

func _ready():
	$CenterContainer/VBoxContainer/PlayAI.pressed.connect(_on_play_ai_pressed)
	$CenterContainer/VBoxContainer/PlayFriend.pressed.connect(_on_play_friend_pressed)
	$CenterContainer/VBoxContainer/Levels.pressed.connect(_on_levels_pressed)
	
	spawn_floating_pieces()
	animate_entrance()

func spawn_floating_pieces():
	var container = $FloatingPieces
	for i in range(12):
		var p = TextureRect.new()
		p.texture = piece_tex
		p.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		var s = randf_range(48, 96)
		p.custom_minimum_size = Vector2(s, s)
		p.size = Vector2(s, s)
		p.position = Vector2(randf_range(0, 720), randf_range(0, 1280))
		p.pivot_offset = Vector2(s/2, s/2)

		p.set_script(load("res://scripts/floating_piece.gd"))
		p.speed = randf_range(20, 60)
		p.rot_speed = randf_range(-1.0, 1.0)
		container.add_child(p)

func animate_entrance():
	var title = $CenterContainer/VBoxContainer/Label
	var buttons = [
		$CenterContainer/VBoxContainer/PlayAI,
		$CenterContainer/VBoxContainer/PlayFriend,
		$CenterContainer/VBoxContainer/Levels
	]
	
	# Initial states
	title.modulate.a = 0
	title.position.y -= 50
	
	for b in buttons:
		b.modulate.a = 0
		b.scale = Vector2(0.8, 0.8)
		b.pivot_offset = b.size / 2
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Title animation
	tween.tween_property(title, "modulate:a", 1.0, 0.6)
	tween.tween_property(title, "position:y", title.position.y + 50, 0.8)
	
	# Buttons stagger
	for i in range(buttons.size()):
		var b = buttons[i]
		var t = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		t.stop()
		get_tree().create_timer(0.3 + i * 0.15).timeout.connect(func():
			t.play()
			t.tween_property(b, "modulate:a", 1.0, 0.4)
			t.tween_property(b, "scale", Vector2(1.0, 1.0), 0.6)
		)

func _on_play_ai_pressed():
	GameManager.current_mode = GameManager.Mode.PV_AI
	SceneTransition.change_scene("res://scenes/main.tscn")

func _on_play_friend_pressed():
	GameManager.current_mode = GameManager.Mode.PV_P
	SceneTransition.change_scene("res://scenes/main.tscn")

func _on_levels_pressed():
	SceneTransition.change_scene("res://scenes/level_select.tscn")
