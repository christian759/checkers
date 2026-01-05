extends Control

@onready var bubble = $ScrollContainer/VBoxContainer/Content/ModeSection/Card/VBox/SegmentedControl/Bubble
@onready var ai_btn = $ScrollContainer/VBoxContainer/Content/ModeSection/Card/VBox/SegmentedControl/Buttons/AiBtn
@onready var friend_btn = $ScrollContainer/VBoxContainer/Content/ModeSection/Card/VBox/SegmentedControl/Buttons/FriendBtn

@onready var ai_settings = $ScrollContainer/VBoxContainer/Content/AiSettings
@onready var level_label = $ScrollContainer/VBoxContainer/Content/AiSettings/LevelSection/Card/VBox/HBox/Value
@onready var level_slider = $ScrollContainer/VBoxContainer/Content/AiSettings/LevelSection/Card/VBox/LevelSlider
@onready var start_toggle = $ScrollContainer/VBoxContainer/Content/AiSettings/StartSection/Card/HBox/StartToggle
@onready var theme_grid = $ScrollContainer/VBoxContainer/Content/ThemeSection/Card/VBox/Grid
@onready var start_button = $ScrollContainer/VBoxContainer/Footer/StartButton

var selected_mode = 0 # 0: AI, 1: Friend
var selected_theme_index = 0

func _ready():
	# Segmented Mode Control
	ai_btn.pressed.connect(_on_mode_toggled.bind(0))
	friend_btn.pressed.connect(_on_mode_toggled.bind(1))
	
	# AI Level
	level_slider.value_changed.connect(_on_level_changed)
	_on_level_changed(1)
	
	# Themes
	_setup_premium_theme_grid()
	
	# Start
	start_button.pressed.connect(_on_start_pressed)
	_animate_start_button()

func _animate_start_button():
	var tween = create_tween().set_loops()
	tween.tween_property(start_button, "scale", Vector2(1.05, 1.05), 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(start_button, "scale", Vector2(1.0, 1.0), 0.8).set_trans(Tween.TRANS_SINE)

func _on_mode_toggled(index):
	if selected_mode == index: return
	selected_mode = index
	
	var target_x = 4.0 if index == 0 else bubble.get_parent().size.x / 2.0 + 2.0
	var target_width = bubble.get_parent().size.x / 2.0 - 6.0
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(bubble, "position:x", target_x, 0.4).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(bubble, "size:x", target_width, 0.4).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	# Color labels
	var ai_color = Color.WHITE if index == 0 else Color("#668866")
	var friend_color = Color.WHITE if index == 1 else Color("#668866")
	tween.tween_property(ai_btn, "theme_override_colors/font_color", ai_color, 0.2)
	tween.tween_property(friend_btn, "theme_override_colors/font_color", friend_color, 0.2)
	
	# Animate AI Settings visibility
	if index == 0:
		ai_settings.visible = true
		ai_settings.modulate.a = 0
		ai_settings.position.y += 20
		var show_tween = create_tween().set_parallel(true)
		show_tween.tween_property(ai_settings, "modulate:a", 1.0, 0.3)
		show_tween.tween_property(ai_settings, "position:y", ai_settings.position.y - 20, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		var hide_tween = create_tween().set_parallel(true)
		hide_tween.tween_property(ai_settings, "modulate:a", 0.0, 0.2)
		hide_tween.tween_callback(func(): ai_settings.visible = false).set_delay(0.2)

func _on_level_changed(value):
	level_label.text = "Lv " + str(int(value))
	# Subtle scale pop on value change
	var tween = create_tween()
	tween.tween_property(level_label, "scale", Vector2(1.2, 1.2), 0.05)
	tween.tween_property(level_label, "scale", Vector2(1.0, 1.0), 0.1)

func _setup_premium_theme_grid():
	for i in range(GameManager.BOARD_THEMES.size()):
		var theme = GameManager.BOARD_THEMES[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(80, 80)
		btn.pivot_offset = Vector2(40, 40)
		btn.flat = true
		
		var panel = Panel.new()
		panel.name = "Circle"
		panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var sb = StyleBoxFlat.new()
		sb.bg_color = theme.dark
		sb.set_corner_radius_all(40)
		sb.border_width_left = 6
		sb.border_width_top = 6
		sb.border_width_right = 6
		sb.border_width_bottom = 6
		sb.border_color = Color("#2ecc71") if i == selected_theme_index else Color.TRANSPARENT
		sb.shadow_color = Color(0, 0, 0, 0.15)
		sb.shadow_size = 8
		
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
			tween.tween_property(sb, "border_color", Color("#2ecc71"), 0.2)
			tween.tween_property(other_btn, "scale", Vector2(1.1, 1.1), 0.2).set_trans(Tween.TRANS_BACK)
		else:
			tween.tween_property(sb, "border_color", Color.TRANSPARENT, 0.2)
			tween.tween_property(other_btn, "scale", Vector2(1.0, 1.0), 0.2)

func _on_start_pressed():
	var mode = GameManager.Mode.PV_AI if selected_mode == 0 else GameManager.Mode.PV_P
	var ai_level = int(level_slider.value)
	var start_side = GameManager.Side.PLAYER if start_toggle.button_pressed else GameManager.Side.AI
	
	# Start scale pop
	var tween = create_tween()
	tween.tween_property(start_button, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_callback(func(): GameManager.start_custom_game(mode, ai_level, selected_theme_index, start_side))
