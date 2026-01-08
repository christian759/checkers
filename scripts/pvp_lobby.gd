extends Control

@onready var mode_bubble = %ModeBubble
@onready var ai_btn = $ScrollContainer/VBox/Content/ModeSection/VBox/SegmentedControl/Buttons/AiBtn
@onready var friend_btn = $ScrollContainer/VBox/Content/ModeSection/VBox/SegmentedControl/Buttons/FriendBtn

@onready var first_bubble = %FirstBubble
@onready var player_first_btn = %PlayerFirstBtn
@onready var ai_first_btn = %AiFirstBtn

@onready var ai_settings = %AiSettings
@onready var level_label = %LevelLabel
@onready var level_slider = %LevelSlider
@onready var theme_grid = %ThemeGrid
@onready var start_button = %StartButton

var selected_mode = 0 # 0: AI, 1: Friend
var selected_start_side = 0 # 0: Player, 1: AI
var selected_theme_index = 0

func _ready():
	_setup_signals()
	_refresh_bubbles(true)
	_setup_premium_theme_grid()
	_animate_start_button()

func _setup_signals():
	ai_btn.pressed.connect(_on_mode_toggled.bind(0))
	friend_btn.pressed.connect(_on_mode_toggled.bind(1))
	
	player_first_btn.pressed.connect(_on_first_toggled.bind(0))
	ai_first_btn.pressed.connect(_on_first_toggled.bind(1))
	
	level_slider.value_changed.connect(_on_level_changed)
	start_button.pressed.connect(_on_start_pressed)

func _animate_start_button():
	var tween = create_tween().set_loops()
	tween.tween_property(start_button, "scale", Vector2(1.02, 1.02), 1.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property(start_button, "scale", Vector2(1.0, 1.0), 1.2).set_trans(Tween.TRANS_SINE)

func _on_mode_toggled(index):
	if selected_mode == index: return
	selected_mode = index
	_refresh_bubbles()
	
	# Animate AI Settings visibility
	if index == 0:
		ai_settings.visible = true
		ai_settings.modulate.a = 0
		var show_tween = create_tween()
		show_tween.tween_property(ai_settings, "modulate:a", 1.0, 0.3)
	else:
		var hide_tween = create_tween()
		hide_tween.tween_property(ai_settings, "modulate:a", 0.0, 0.2)
		hide_tween.tween_callback(func(): ai_settings.visible = false)

func _on_first_toggled(index):
	if selected_start_side == index: return
	selected_start_side = index
	_refresh_bubbles()

func _refresh_bubbles(immediate: bool = false):
	var duration = 0.0 if immediate else 0.4
	
	# Mode Bubble
	var mode_target_x = 4.0 if selected_mode == 0 else mode_bubble.get_parent().size.x / 2.0 + 2.0
	var mode_target_width = mode_bubble.get_parent().size.x / 2.0 - 6.0
	
	var mt = create_tween().set_parallel(true)
	mt.tween_property(mode_bubble, "position:x", mode_target_x, duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	mt.tween_property(mode_bubble, "size:x", mode_target_width, duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	# First Bubble
	var first_target_x = 4.0 if selected_start_side == 0 else first_bubble.get_parent().size.x / 2.0 + 2.0
	var first_target_width = first_bubble.get_parent().size.x / 2.0 - 6.0
	
	var ft = create_tween().set_parallel(true)
	ft.tween_property(first_bubble, "position:x", first_target_x, duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	ft.tween_property(first_bubble, "size:x", first_target_width, duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	# Label Colors
	var active_c = Color.WHITE
	var inactive_c = Color("#889988")
	
	mt.tween_property(ai_btn, "theme_override_colors/font_color", active_c if selected_mode == 0 else inactive_c, 0.2)
	mt.tween_property(friend_btn, "theme_override_colors/font_color", active_c if selected_mode == 1 else inactive_c, 0.2)
	
	ft.tween_property(player_first_btn, "theme_override_colors/font_color", active_c if selected_start_side == 0 else inactive_c, 0.2)
	ft.tween_property(ai_first_btn, "theme_override_colors/font_color", active_c if selected_start_side == 1 else inactive_c, 0.2)

func _on_level_changed(value):
	level_label.text = "Lv " + str(int(value))

func _setup_premium_theme_grid():
	for i in range(GameManager.BOARD_THEMES.size()):
		var theme = GameManager.BOARD_THEMES[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(70, 70)
		btn.pivot_offset = Vector2(35, 35)
		btn.flat = true
		
		var panel = Panel.new()
		panel.name = "Circle"
		panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var sb = StyleBoxFlat.new()
		sb.bg_color = theme.dark
		sb.set_corner_radius_all(35)
		sb.border_width_left = 4
		sb.border_width_top = 4
		sb.border_width_right = 4
		sb.border_width_bottom = 4
		sb.border_color = Color("#00ff88") if i == selected_theme_index else Color.TRANSPARENT
		
		panel.add_theme_stylebox_override("panel", sb)
		btn.add_child(panel)
		
		btn.pressed.connect(_on_theme_tapped.bind(i, btn))
		theme_grid.add_child(btn)

func _on_theme_tapped(index, btn):
	if selected_theme_index == index: return
	selected_theme_index = index
	
	for other_btn in theme_grid.get_children():
		var p = other_btn.get_node("Circle")
		var sb = p.get_theme_stylebox("panel")
		var tween = create_tween().set_parallel(true)
		
		if other_btn == btn:
			tween.tween_property(sb, "border_color", Color("#00ff88"), 0.2)
			tween.tween_property(other_btn, "scale", Vector2(1.1, 1.1), 0.2).set_trans(Tween.TRANS_BACK)
		else:
			tween.tween_property(sb, "border_color", Color.TRANSPARENT, 0.2)
			tween.tween_property(other_btn, "scale", Vector2(1.0, 1.0), 0.2)

func _on_start_pressed():
	var mode = GameManager.Mode.PV_AI if selected_mode == 0 else GameManager.Mode.PV_P
	var ai_level = int(level_slider.value)
	var start_side = GameManager.Side.PLAYER if selected_start_side == 0 else GameManager.Side.AI
	
	var tween = create_tween()
	tween.tween_property(start_button, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_callback(func(): GameManager.start_custom_game(mode, ai_level, selected_theme_index, start_side))
