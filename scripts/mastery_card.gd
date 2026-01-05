extends PanelContainer

@onready var title_label = $VBoxContainer/Title
@onready var grid = $VBoxContainer/GridContainer

var level_icon_scene = preload("res://scenes/mastery_level_icon.tscn")

func setup(rank_name: String, start_level: int, accent_color: Color, current_global_level: int):
	title_label.text = rank_name
	
	# Apply theme colors
	var sb = get_theme_stylebox("panel").duplicate()
	sb.bg_color = Color(0.12, 0.12, 0.15, 0.95)
	sb.border_color = accent_color.darkened(0.3)
	sb.border_width_top = 4 # Accent top border
	add_theme_stylebox_override("panel", sb)
	
	title_label.add_theme_color_override("font_color", accent_color)

	for i in range(20):
		var level_num = start_level + i
		var icon = level_icon_scene.instantiate()
		grid.add_child(icon)
		
		var state = 0 # LOCKED
		if level_num < current_global_level:
			state = 2 # COMPLETED
		elif level_num == current_global_level:
			state = 1 # CURRENT
			
		icon.setup(level_num, state, accent_color)
