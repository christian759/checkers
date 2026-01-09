extends Control

@onready var bubble = %Bubble
@onready var ai_btn = %AiBtn
@onready var friend_btn = %FriendBtn

@onready var order_bubble = %OrderBubble
@onready var me_btn = %MeBtn
@onready var opp_btn = %OpponentBtn

@onready var clock_bubble = %ClockBubble
@onready var clock_off_btn = %ClockOffBtn
@onready var clock_1m_btn = %Clock1mBtn
@onready var clock_5m_btn = %Clock5mBtn
@onready var clock_10m_btn = %Clock10mBtn

@onready var ai_settings = %AiSettings
@onready var level_label = %Value
@onready var level_slider = %LevelSlider
@onready var theme_grid = %Grid
@onready var start_button = %StartButton

var selected_mode = 0 # 0: AI, 1: Friend
var selected_order = 0 # 0: Me, 1: Opponent
var selected_clock_index = 0 # 0: Off, 1: 1m, 2: 5m, 3: 10m
var selected_theme_index = 0

func _ready():
	# Mode Selection
	ai_btn.pressed.connect(_on_mode_toggled.bind(0))
	friend_btn.pressed.connect(_on_mode_toggled.bind(1))
	
	# Order Selection
	me_btn.pressed.connect(_on_order_toggled.bind(0))
	opp_btn.pressed.connect(_on_order_toggled.bind(1))
	
	# Clock Selection
	clock_off_btn.pressed.connect(_on_clock_toggled.bind(0))
	clock_1m_btn.pressed.connect(_on_clock_toggled.bind(1))
	clock_5m_btn.pressed.connect(_on_clock_toggled.bind(2))
	clock_10m_btn.pressed.connect(_on_clock_toggled.bind(3))
	
	# AI Level
	level_slider.value_changed.connect(_on_level_changed)
	_on_level_changed(40)
	
	# Themes
	_setup_theme_grid()
	
	# Start
	start_button.pressed.connect(_on_start_pressed)

func _on_mode_toggled(index):
	if selected_mode == index: return
	selected_mode = index
	
	_animate_segmented(bubble, index, [ai_btn, friend_btn])
	
	# Hide/Show AI settings
	var target_a = 1.0 if index == 0 else 0.0
	var tween = create_tween()
	tween.tween_property(ai_settings, "modulate:a", target_a, 0.2)
	tween.tween_callback(func(): ai_settings.visible = (index == 0))

func _on_order_toggled(index):
	if selected_order == index: return
	selected_order = index
	_animate_segmented(order_bubble, index, [me_btn, opp_btn])

func _on_clock_toggled(index):
	if selected_clock_index == index: return
	selected_clock_index = index
	_animate_segmented(clock_bubble, index, [clock_off_btn, clock_1m_btn, clock_5m_btn, clock_10m_btn])

func _animate_segmented(target_bubble, index, buttons):
	var parent_width = target_bubble.get_parent().size.x
	var btn_count = buttons.size()
	var btn_width = parent_width / float(btn_count)
	
	var target_x = (index * btn_width) + 4.0
	var target_width = btn_width - 8.0
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(target_bubble, "position:x", target_x, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(target_bubble, "size:x", target_width, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	for i in range(buttons.size()):
		var color = Color.WHITE if i == index else Color("#7f8c8d")
		tween.tween_property(buttons[i], "theme_override_colors/font_color", color, 0.2)

func _on_level_changed(value):
	level_label.text = "Lv " + str(int(value))

func _setup_theme_grid():
	# Clear existing if any
	for c in theme_grid.get_children(): c.queue_free()
	
	for i in range(GameManager.BOARD_THEMES.size()):
		var theme_data = GameManager.BOARD_THEMES[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(70, 70)
		btn.flat = true
		
		var panel = Panel.new()
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		
		var sb = StyleBoxFlat.new()
		sb.bg_color = theme_data.dark
		sb.corner_radius_top_left = 12
		sb.corner_radius_top_right = 12
		sb.corner_radius_bottom_right = 12
		sb.corner_radius_bottom_left = 12
		sb.border_width_left = 4 if i == selected_theme_index else 0
		sb.border_width_top = 4 if i == selected_theme_index else 0
		sb.border_width_right = 4 if i == selected_theme_index else 0
		sb.border_width_bottom = 4 if i == selected_theme_index else 0
		sb.border_color = Color("#2ecc71")
		
		panel.add_theme_stylebox_override("panel", sb)
		btn.add_child(panel)
		btn.pressed.connect(_on_theme_selected.bind(i))
		theme_grid.add_child(btn)

func _on_theme_selected(index):
	selected_theme_index = index
	for i in range(theme_grid.get_child_count()):
		var btn = theme_grid.get_child(i)
		var panel = btn.get_child(0)
		var sb = panel.get_theme_stylebox("panel")
		sb.border_width_left = 4 if i == index else 0
		sb.border_width_top = 4 if i == index else 0
		sb.border_width_right = 4 if i == index else 0
		sb.border_width_bottom = 4 if i == index else 0

func _on_start_pressed():
	var mode = GameManager.Mode.PV_AI if selected_mode == 0 else GameManager.Mode.PV_P
	var ai_level = int(level_slider.value)
	var start_side = GameManager.Side.PLAYER if selected_order == 0 else GameManager.Side.AI
	
	var clock_times = [0, 60, 300, 600]
	var time_limit = clock_times[selected_clock_index]
	
	GameManager.start_custom_game(mode, ai_level, selected_theme_index, start_side, time_limit)
