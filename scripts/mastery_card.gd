extends PanelContainer

@onready var title_label = $VBoxContainer/Header/Title
@onready var grid = $VBoxContainer/MarginContainer/GridContainer
@onready var header = $VBoxContainer/Header
@onready var progress_bar = $VBoxContainer/Footer/ProgressBar

var level_icon_scene = preload("res://scenes/mastery_level_icon.tscn")

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pivot_offset = size / 2

func setup(rank_name: String, start_level: int, accent_color: Color):
	title_label.text = rank_name
	
	# Glass Header Color
	var header_sb = header.get_theme_stylebox("panel").duplicate()
	header_sb.border_color = Color(accent_color, 0.4)
	header_sb.bg_color = Color(accent_color, 0.05)
	header.add_theme_stylebox_override("panel", header_sb)
	
	title_label.add_theme_color_override("font_color", accent_color)

	var completed_count = 0
	for i in range(20):
		var level_num = start_level + i
		var icon = level_icon_scene.instantiate()
		grid.add_child(icon)
		
		var state = 0 # LOCKED
		
		# LOGIC:
		# 1. If level is in completed_levels -> COMPLETED (2)
		# 2. If level is NOT completed but is <= max_unlocked_level -> CURRENT/UNLOCKED (1)
		# 3. Else -> LOCKED (0)
		
		if level_num in GameManager.completed_levels:
			state = 2 # COMPLETED
			completed_count += 1
		elif level_num <= GameManager.max_unlocked_level:
			state = 1 # UNLOCKED (Playable)
		else:
			state = 0 # LOCKED
			
		icon.setup(level_num, state, accent_color)
	
	# Update Progress Bar
	progress_bar.value = (float(completed_count) / 20.0) * 100.0
	var pb_filled = StyleBoxFlat.new()
	pb_filled.bg_color = accent_color
	pb_filled.corner_radius_top_left = 6
	pb_filled.corner_radius_bottom_left = 6
	progress_bar.add_theme_stylebox_override("fill", pb_filled)

func _on_mouse_entered():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.02, 1.02), 0.2).set_trans(Tween.TRANS_SINE)
	if has_node("BackgroundGlow"):
		tween.tween_property($BackgroundGlow, "modulate:a", 0.1, 0.2)

func _on_mouse_exited():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE)
	if has_node("BackgroundGlow"):
		tween.tween_property($BackgroundGlow, "modulate:a", 0.0, 0.2)
