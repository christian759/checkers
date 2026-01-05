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

func setup(rank_name: String, start_level: int, accent_color: Color, current_global_level: int):
	title_label.text = rank_name
	
	# Glass Header Color
	var header_sb = header.get_theme_stylebox("panel")
	if not header_sb is StyleBoxFlat:
		header_sb = StyleBoxFlat.new()
	else:
		header_sb = header_sb.duplicate()
		
	header_sb.border_color = Color(accent_color, 0.3)
	header_sb.bg_color = Color(accent_color, 0.1)
	header.add_theme_stylebox_override("panel", header_sb)
	
	title_label.add_theme_color_override("font_color", accent_color)

	var completed_count = 0
	for i in range(20):
		var level_num = start_level + i
		var icon = level_icon_scene.instantiate()
		grid.add_child(icon)
		
		var state = 0 # LOCKED
		if level_num < current_global_level:
			state = 2 # COMPLETED
			completed_count += 1
		elif level_num == current_global_level:
			state = 1 # CURRENT
			
		icon.setup(level_num, state, accent_color)
	
	# Update Progress Bar
	progress_bar.value = (float(completed_count) / 20.0) * 100.0
	var pb_sb = StyleBoxFlat.new()
	pb_sb.bg_color = accent_color
	pb_sb.set_corner_radius_all(10)
	progress_bar.add_theme_stylebox_override("fill", pb_sb)

func _on_mouse_entered():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property($BackgroundGlow, "color", Color(1, 1, 1, 0.08), 0.3)

func _on_mouse_exited():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_property($BackgroundGlow, "color", Color(1, 1, 1, 0.02), 0.3)
