extends Control

var piece_tex = load("res://assets/textures/piece_player.svg")

@onready var buttons_container = $ContentLayer/GlassPanel
@onready var glass_panel = $ContentLayer/GlassPanel
@onready var logo = $ContentLayer/GlassPanel/LogoContainer/LogoTexture
@onready var accent1 = $ParallaxLayers/Accent1
@onready var accent2 = $ParallaxLayers/Accent2

func _ready():
	buttons_container.get_node("PlayAI").pressed.connect(_on_play_ai_pressed)
	buttons_container.get_node("PlayFriend").pressed.connect(_on_play_friend_pressed)
	buttons_container.get_node("Levels").pressed.connect(_on_levels_pressed)
	buttons_container.get_node("DailyChallenge").pressed.connect(_on_daily_pressed)
	
	spawn_floating_pieces()
	animate_entrance()

func _process(delta):
	# Parallax effect based on mouse position
	var mouse_pos = get_viewport().get_mouse_position()
	var center = get_viewport_rect().size / 2
	var offset = (mouse_pos - center) / center # Range -1 to 1
	
	accent1.position.x = lerp(accent1.position.x, -228.0 + offset.x * 30.0, delta * 2.0)
	accent1.position.y = lerp(accent1.position.y, 114.0 + offset.y * 30.0, delta * 2.0)
	
	accent2.position.x = lerp(accent2.position.x, 370.0 - offset.x * 20.0, delta * 2.0)
	accent2.position.y = lerp(accent2.position.y, 649.0 - offset.y * 20.0, delta * 2.0)
	
	glass_panel.position.x = lerp(glass_panel.position.x, (get_viewport_rect().size.x - 400)/2 + offset.x * 10.0, delta * 3.0)
	glass_panel.position.y = lerp(glass_panel.position.y, (get_viewport_rect().size.y - 700)/2 + offset.y * 10.0, delta * 3.0)

func spawn_floating_pieces():
	var container = $FloatingPieces
	for i in range(15):
		var p = TextureRect.new()
		p.texture = piece_tex
		p.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		var s = randf_range(40, 120)
		p.custom_minimum_size = Vector2(s, s)
		p.size = Vector2(s, s)
		p.position = Vector2(randf_range(0, 720), randf_range(0, 1280))
		p.pivot_offset = Vector2(s/2, s/2)
		p.modulate.a = 0 # Initially hidden

		p.set_script(load("res://scripts/floating_piece.gd"))
		p.speed = randf_range(15, 45)
		p.rot_speed = randf_range(-0.5, 0.5)
		container.add_child(p)

func animate_entrance():
	# Initial states for animation
	glass_panel.modulate.a = 0
	glass_panel.scale = Vector2(0.9, 0.9)
	logo.scale = Vector2(0, 0)
	
	var buttons = [
		buttons_container.get_node("PlayAI"),
		buttons_container.get_node("PlayFriend"),
		buttons_container.get_node("DailyChallenge"),
		buttons_container.get_node("Levels")
	]
	
	for b in buttons:
		b.modulate.a = 0
		b.position.x += 40
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	# Main panel fade in
	tween.tween_property(glass_panel, "modulate:a", 1.0, 1.0)
	tween.tween_property(glass_panel, "scale", Vector2(1.0, 1.0), 1.2).set_trans(Tween.TRANS_EXPO)
	
	# Logo pop
	var logo_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	logo_tween.tween_interval(0.4)
	logo_tween.tween_property(logo, "scale", Vector2(1.0, 1.0), 0.8)
	
	# Stagger buttons
	for i in range(buttons.size()):
		var b = buttons[i]
		var bt = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		bt.tween_interval(0.6 + i * 0.12)
		bt.tween_property(b, "modulate:a", 1.0, 0.5)
		bt.parallel().tween_property(b, "position:x", b.position.x - 40, 0.6)

func _on_play_ai_pressed():
	GameManager.reset_game()
	GameManager.is_daily_challenge = false
	SceneTransition.change_scene("res://scenes/map_menu.tscn")

func _on_play_friend_pressed():
	GameManager.reset_game()
	GameManager.is_daily_challenge = false
	GameManager.current_mode = GameManager.Mode.PV_P
	SceneTransition.change_scene("res://scenes/main.tscn")

func _on_levels_pressed():
	GameManager.reset_game()
	GameManager.is_daily_challenge = false
	SceneTransition.change_scene("res://scenes/map_menu.tscn")

func _on_daily_pressed():
	GameManager.reset_game()
	GameManager.is_daily_challenge = true
	GameManager.current_level = 10 
	GameManager.current_mode = GameManager.Mode.PV_AI
	SceneTransition.change_scene("res://scenes/main.tscn")
