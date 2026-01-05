extends Control

@onready var bubble = %ActiveBubble
@onready var ai_btn = %AiBtn
@onready var friend_btn = %FriendBtn
@onready var ai_settings = %AiSettings
@onready var level_label = %LevelValue
@onready var level_slider = %LevelSlider
@onready var start_bubble = %StartBubble
@onready var you_btn = %YouBtn
@onready var ai_start_btn = %AiStartBtn
@onready var theme_grid = %ThemeGrid
@onready var start_button = %StartMatchBtn

var selected_mode = 0
var selected_start_side = 0
var selected_theme_index = 0

func _ready():
	ai_btn.pressed.connect(_on_mode_toggled.bind(0))
	friend_btn.pressed.connect(_on_mode_toggled.bind(1))
	you_btn.pressed.connect(_on_start_side_toggled.bind(0))
	ai_start_btn.pressed.connect(_on_start_side_toggled.bind(1))
	
	level_slider.value_changed.connect(_on_level_changed)
	_on_level_changed(level_slider.value)
	
	_setup_theme_grid()
	start_button.pressed.connect(_on_start_pressed)

func _on_mode_toggled(index):
	if selected_mode == index: return
	selected_mode = index
	
	var target_x = 6.0 if index == 0 else bubble.get_parent().size.x / 2.0 + 3.0
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(bubble, "position:x", target_x, 0.4)
	
	var active_color = Color.WHITE
	var inactive_color = Color("#1B4332", 0.6)
	tween.tween_property(ai_btn, "theme_override_colors/font_color", active_color if index == 0 else inactive_color, 0.2)
	tween.tween_property(friend_btn, "theme_override_colors/font_color", active_color if index == 1 else inactive_color, 0.2)
	
	if index == 0:
		ai_settings.visible = true
		create_tween().tween_property(ai_settings, "modulate:a", 1.0, 0.3)
	else:
		var h = create_tween()
		h.tween_property(ai_settings, "modulate:a", 0.0, 0.2)
		h.finished.connect(func(): ai_settings.visible = false)

func _on_start_side_toggled(index):
	if selected_start_side == index: return
	selected_start_side = index
	
	var target_x = 6.0 if index == 0 else start_bubble.get_parent().size.x / 2.0 + 3.0
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(start_bubble, "position:x", target_x, 0.4)
	
	var active_color = Color.WHITE
	var inactive_color = Color("#1B4332", 0.6)
	tween.tween_property(you_btn, "theme_override_colors/font_color", active_color if index == 0 else inactive_color, 0.2)
	tween.tween_property(ai_start_btn, "theme_override_colors/font_color", active_color if index == 1 else inactive_color, 0.2)

func _on_level_changed(value):
	level_label.text = str(int(value))

func _setup_theme_grid():
	for i in range(GameManager.BOARD_THEMES.size()):
		var theme = GameManager.BOARD_THEMES[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(80, 80)
		btn.flat = true
		
		var circle = Panel.new()
		circle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		circle.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		
		var sb = StyleBoxFlat.new()
		sb.bg_color = theme.dark
		sb.set_corner_radius_all(40)
		sb.set_border_width_all(4)
		sb.border_color = Color("#1B4332") if i == selected_theme_index else Color.WHITE
		
		circle.add_theme_stylebox_override("panel", sb)
		btn.add_child(circle)
		btn.pressed.connect(_on_theme_selected.bind(i, btn))
		theme_grid.add_child(btn)

func _on_theme_selected(index, btn):
	if selected_theme_index == index: return
	selected_theme_index = index
	for child in theme_grid.get_children():
		var sb = child.get_child(0).get_theme_stylebox("panel")
		sb.border_color = Color("#1B4332") if child == btn else Color.WHITE
		child.scale = Vector2(1.1, 1.1) if child == btn else Vector2(1.0, 1.0)

func _on_start_pressed():
	var mode = GameManager.Mode.PV_AI if selected_mode == 0 else GameManager.Mode.PV_P
	var start_side = GameManager.Side.PLAYER if selected_start_side == 0 else GameManager.Side.AI
	GameManager.start_custom_game(mode, int(level_slider.value), selected_theme_index, start_side)
