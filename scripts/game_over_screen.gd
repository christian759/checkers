extends Control

@onready var title_label = $Panel/Title

@onready var panel = $Panel
@onready var star_container = $Panel/StarContainer
@onready var reward_label = $Panel/RewardLabel
@onready var next_btn = $Panel/HBox/NextLevel

var is_win = false

func setup(winner_side, has_next_level):
	is_win = (winner_side == GameManager.Side.PLAYER)
	
	# Initial states for animation
	panel.scale = Vector2.ZERO
	panel.modulate.a = 0
	star_container.modulate.a = 0
	reward_label.modulate.a = 0
	
	if winner_side == GameManager.Side.PLAYER:
		title_label.text = "VICTORY!"
		title_label.add_theme_color_override("font_color", Color("#58cc02"))
		$Confetti.emitting = true
		
		if GameManager.current_mode == GameManager.Mode.PV_AI:
			GameManager.add_coins(GameManager.WIN_REWARD)
			reward_label.text = "+%d COINS" % GameManager.WIN_REWARD
			reward_label.visible = true
			next_btn.visible = has_next_level
		else:
			reward_label.visible = false
			next_btn.visible = false
	else:
		title_label.text = "DEFEAT"
		title_label.add_theme_color_override("font_color", Color("#ff4b4b"))
		star_container.visible = false
		reward_label.visible = false
		next_btn.visible = false
	
	# Entrance Animation
	var tween = create_tween().set_parallel(true)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate:a", 1.0, 0.3)
	
	await tween.finished
	
	if is_win:
		_animate_stars()

func _animate_stars():
	var delay = 0.0
	for star in star_container.get_children():
		var t = create_tween()
		star.scale = Vector2.ZERO
		t.tween_interval(delay)
		t.tween_property(star, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		delay += 0.2
	
	var t2 = create_tween()
	t2.tween_property(star_container, "modulate:a", 1.0, 0.2)
	t2.tween_property(reward_label, "modulate:a", 1.0, 0.2)

func _on_restart_pressed():
	GameManager.reset_game()
	SceneTransition.change_scene("res://scenes/main.tscn")

func _on_menu_pressed():
	GameManager.reset_game()
	SceneTransition.change_scene("res://scenes/level_select.tscn")

func _on_next_level_pressed():
	GameManager.current_level += 1
	GameManager.reset_game()
	SceneTransition.change_scene("res://scenes/main.tscn")
