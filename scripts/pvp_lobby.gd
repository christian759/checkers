extends Control

@onready var bubble = %Bubble
@onready var ai_btn = %AiBtn
@onready var friend_btn = %FriendBtn

@onready var order_bubble = %OrderBubble
@onready var me_btn = %MeBtn
@onready var opp_btn = %OpponentBtn

@onready var ai_settings = %AiSettings
@onready var level_label = %Value
@onready var level_slider = %LevelSlider
@onready var theme_grid = %Grid
@onready var start_button = %StartButton

var selected_mode = 0 # 0: AI, 1: Friend
var selected_order = 0 # 0: Me, 1: Opponent
var selected_theme_index = 0

func _ready():
	# Mode Selection
	ai_btn.pressed.connect(_on_mode_toggled.bind(0))
	friend_btn.pressed.connect(_on_mode_toggled.bind(1))
	
	# Order Selection
	me_btn.pressed.connect(_on_order_toggled.bind(0))
	opp_btn.pressed.connect(_on_order_toggled.bind(1))
	
	# AI Level
	level_slider.value_changed.connect(_on_level_changed)
	_on_level_changed(1)
	
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

func _animate_segmented(target_bubble, index, buttons):
	var parent_width = target_bubble.get_parent().size.x
	var target_x = 4.0 if index == 0 else parent_width / 2.0 + 2.0
	var target_width = parent_width / 2.0 - 10.0
	
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
	
	GameManager.start_custom_game(mode, ai_level, selected_theme_index, start_side)
