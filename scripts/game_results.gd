extends Control

@onready var card = $Center/Card
@onready var status_label = $Center/Card/VBox/Status
@onready var info_label = $Center/Card/VBox/LevelInfo
@onready var next_btn = $Center/Card/VBox/Buttons/NextBtn
@onready var retry_btn = $Center/Card/VBox/Buttons/RetryBtn
@onready var home_btn = $Center/Card/VBox/Buttons/HomeBtn
@onready var bg = $ColorRect

func _ready():
	# Initial state for animation
	card.scale = Vector2.ZERO
	bg.modulate.a = 0
	
	next_btn.pressed.connect(_on_next_pressed)
	retry_btn.pressed.connect(_on_retry_pressed)
	home_btn.pressed.connect(_on_home_pressed)

func setup(winner):
	var is_pvp = (GameManager.current_mode == GameManager.Mode.PV_P)
	var is_victory = (winner == GameManager.Side.PLAYER)
	
	if is_victory:
		if is_pvp:
			status_label.text = "WHITE WINS!"
		else:
			status_label.text = "VICTORY!"
		status_label.add_theme_color_override("font_color", Color("#2ecc71"))
		
		if GameManager.is_daily_challenge:
			info_label.text = "DAILY CHALLENGE COMPLETED!"
			next_btn.visible = false
		elif GameManager.is_mastery:
			info_label.text = "LEVEL " + str(GameManager.current_level) + " MASTERY"
			next_btn.visible = (GameManager.current_level < 200)
			next_btn.text = "NEXT LEVEL"
		else:
			# Custom AI or PvP
			info_label.text = "MATCH COMPLETED"
			next_btn.visible = true
			next_btn.text = "REMATCH"
	else:
		if is_pvp:
			status_label.text = "RED WINS!"
			status_label.add_theme_color_override("font_color", Color("#e67e22"))
			info_label.text = "MATCH COMPLETED"
			next_btn.visible = true
			next_btn.text = "REMATCH"
		else:
			status_label.text = "DEFEAT"
			status_label.add_theme_color_override("font_color", Color("#e74c3c"))
			info_label.text = "GIVE IT ANOTHER SHOT"
			next_btn.visible = false
	
	_animate_in()

func _animate_in():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(bg, "modulate:a", 1.0, 0.3)
	tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_next_pressed():
	if GameManager.is_mastery:
		GameManager.start_mastery_level(GameManager.current_level + 1)
	else:
		# Rematch logic: use GameManager to restart with same settings
		GameManager.restart_match()

func _on_retry_pressed():
	GameManager.restart_match()

func _on_home_pressed():
	GameManager.is_daily_challenge = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")
