extends Control

@onready var bubble = %ActiveBubble
@onready var ai_btn = %AiBtn
@onready var friend_btn = %FriendBtn
@onready var ai_settings = %AiSettings
@onready var level_label = %LevelValue
@onready var level_slider = %LevelSlider
@onready var start_toggle = %StartToggle
@onready var theme_grid = %ThemeGrid
@onready var start_button = %StartMatchBtn

var selected_mode = 0 # 0: AI, 1: Friend
var selected_theme_index = 0

func _ready():
	# Mode Toggles
	ai_btn.pressed.connect(_on_mode_toggled.bind(0))
	friend_btn.pressed.connect(_on_mode_toggled.bind(1))
	
	# AI Level Slider
	level_slider.value_changed.connect(_on_level_changed)
	_on_level_changed(level_slider.value)
	
	# Initialize Themes
	_setup_theme_grid()
	
	# Start Button
	start_button.pressed.connect(_on_start_pressed)
	_animate_start_button()

func _animate_start_button():
	var tween = create_tween().set_loops()
	tween.tween_property(start_button, "scale", Vector2(1.03, 1.03), 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(start_button, "scale", Vector2(1.0, 1.0), 1.0).set_trans(Tween.TRANS_SINE)

func _on_mode_toggled(index):
	if selected_mode == index: return
	selected_mode = index
	
	if not bubble: return
	
	# Animate the pill bubble
	var pill_width = bubble.get_parent().size.x
	var target_x = 6.0 if index == 0 else pill_width / 2.0 + 2.0
	var target_width = pill_width / 2.0 - 8.0
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(bubble, "position:x", target_x, 0.4).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(bubble, "size:x", target_width, 0.4).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	# Color labels
	var active_color = Color.WHITE
	var inactive_color = Color("#7f8c8d")
	tween.tween_property(ai_btn, "theme_override_colors/font_color", active_color if index == 0 else inactive_color, 0.2)
	tween.tween_property(friend_btn, "theme_override_colors/font_color", active_color if index == 1 else inactive_color, 0.2)
	
	# Show/Hide AI Settings
	if index == 0:
		ai_settings.visible = true
		ai_settings.modulate.a = 0
		var s_tween = create_tween().set_parallel(true)
		s_tween.tween_property(ai_settings, "modulate:a", 1.0, 0.3)
	else:
		var h_tween = create_tween()
		h_tween.tween_property(ai_settings, "modulate:a", 0.0, 0.2)
		h_tween.finished.connect(func(): ai_settings.visible = false)

func _on_level_changed(value):
	level_label.text = "Lv " + str(int(value))
	var tween = create_tween()
	tween.tween_property(level_label, "scale", Vector2(1.2, 1.2), 0.05)
	tween.tween_property(level_label, "scale", Vector2(1.0, 1.0), 0.1)

func _setup_theme_grid():
	for i in range(GameManager.BOARD_THEMES.size()):
		var theme = GameManager.BOARD_THEMES[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(80, 80)
		btn.flat = true
		
		var circle = Panel.new()
		circle.name = "Circle"
		circle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		circle.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		
		var sb = StyleBoxFlat.new()
		sb.bg_color = theme.dark
		sb.set_corner_radius_all(40)
		sb.border_width_all = 6
		sb.border_color = Color("#2ecc71") if i == selected_theme_index else Color.TRANSPARENT
		sb.shadow_color = Color(0, 0, 0, 0.1)
		sb.shadow_size = 10
		
		circle.add_theme_stylebox_override("panel", sb)
		btn.add_child(circle)
		btn.pressed.connect(_on_theme_selected.bind(i, btn))
		theme_grid.add_child(btn)

func _on_theme_selected(index, btn):
	if selected_theme_index == index: return
	selected_theme_index = index
	
	for child in theme_grid.get_children():
		var c = child.get_node("Circle")
		var sb = c.get_theme_stylebox("panel")
		var tween = create_tween().set_parallel(true)
		if child == btn:
			tween.tween_property(sb, "border_color", Color("#2ecc71"), 0.2)
			tween.tween_property(child, "scale", Vector2(1.1, 1.1), 0.2).set_trans(Tween.TRANS_BACK)
		else:
			tween.tween_property(sb, "border_color", Color.TRANSPARENT, 0.2)
			tween.tween_property(child, "scale", Vector2(1.0, 1.0), 0.2)

func _on_start_pressed():
	var mode = GameManager.Mode.PV_AI if selected_mode == 0 else GameManager.Mode.PV_P
	var ai_val = int(level_slider.value)
	var p_starts = start_toggle.button_pressed
	var start_side = GameManager.Side.PLAYER if p_starts else GameManager.Side.AI
	
	# UI feedback
	var tween = create_tween()
	tween.tween_property(start_button, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_callback(func():
		GameManager.start_custom_game(mode, ai_val, selected_theme_index, start_side)
	)
