extends Control

@onready var mode_grid = %ModeGrid
@onready var level_grid = %LevelGrid
@onready var time_grid = %TimeGrid
@onready var ai_section = %AILevelSection
@onready var play_btn = %PlayBtn

var selected_mode = 0 # 0: AI, 1: Friend
var selected_level = 1 # 1-5
var selected_time = 10 # minutes

var modes = [
	{"name": "vs AI", "id": GameManager.Mode.PV_AI},
	{"name": "vs Friend", "id": GameManager.Mode.PV_P}
]

var levels = [1, 2, 3, 4, 5]

var times = [
	{"name": "1 MIN", "value": 1},
	{"name": "3 MIN", "value": 3},
	{"name": "5 MIN", "value": 5},
	{"name": "10 MIN", "value": 10}
]

func _ready():
	_refresh_ui()
	if play_btn:
		play_btn.pressed.connect(_on_play_pressed)
		_style_play_button()

func _refresh_ui():
	_setup_grid(mode_grid, modes, "name", "_on_mode_selected", selected_mode)
	_setup_grid(level_grid, levels, "", "_on_level_selected", selected_level - 1)
	_setup_grid(time_grid, times, "name", "_on_time_selected", _get_time_index(selected_time))
	
	ai_section.visible = (selected_mode == 0)

func _setup_grid(grid: GridContainer, data: Array, key: String, callback_name: String, active_index: int):
	for child in grid.get_children():
		child.queue_free()
	
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	
	for i in range(data.size()):
		var item = data[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 64)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.text = str(item[key] if key != "" else item)
		
		var is_active = (i == active_index)
		_apply_button_style(btn, is_active)
		
		btn.pressed.connect(Callable(self, callback_name).bind(i))
		grid.add_child(btn)

func _apply_button_style(btn: Button, is_active: bool):
	var sb = StyleBoxFlat.new()
	sb.set_corner_radius_all(20)
	
	if is_active:
		sb.bg_color = GameManager.FOREST
		btn.add_theme_color_override("font_color", Color.WHITE)
	else:
		sb.bg_color = Color.WHITE
		sb.border_width_all = 2
		sb.border_color = Color(0.1, 0.26, 0.2, 0.1)
		btn.add_theme_color_override("font_color", Color(0.1, 0.26, 0.2, 0.6))
	
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb)
	btn.add_theme_stylebox_override("pressed", sb)

func _style_play_button():
	var sb = StyleBoxFlat.new()
	sb.bg_color = GameManager.FOREST
	sb.set_corner_radius_all(32)
	sb.shadow_color = Color(0, 0, 0, 0.1)
	sb.shadow_size = 10
	sb.shadow_offset = Vector2(0, 4)
	play_btn.add_theme_stylebox_override("normal", sb)
	play_btn.add_theme_stylebox_override("hover", sb)
	play_btn.add_theme_stylebox_override("pressed", sb)

func _on_mode_selected(index: int):
	selected_mode = index
	_refresh_ui()

func _on_level_selected(index: int):
	selected_level = levels[index]
	_refresh_ui()

func _on_time_selected(index: int):
	selected_time = times[index].value
	_refresh_ui()

func _get_time_index(val: int) -> int:
	for i in range(times.size()):
		if times[i].value == val: return i
	return 0

func _on_play_pressed():
	var mode = modes[selected_mode].id
	# AI Level maps to blunder rate or depth in GameManager
	# For now, let's pass it as a simple difficulty multiplier or similar
	GameManager.start_custom_game(mode, selected_level * 20, selected_time, GameManager.Side.PLAYER)
