extends Button

@onready var label = $Label

enum State {LOCKED, CURRENT, COMPLETED}

func setup(level_num: int, state: State, accent_color: Color):
	text = "" # Use label instead
	label.text = str(level_num)
	
	var sb = StyleBoxFlat.new()
	sb.set_corner_radius_all(100) # Circle
	sb.set_border_width_all(2)
	
	match state:
		State.LOCKED:
			sb.bg_color = Color(0.2, 0.2, 0.2, 0.5)
			sb.border_color = Color(0.3, 0.3, 0.3, 0.5)
			label.modulate = Color(0.5, 0.5, 0.5, 0.8)
		State.CURRENT:
			sb.bg_color = accent_color.darkened(0.5)
			sb.border_color = accent_color
			sb.shadow_color = accent_color
			sb.shadow_size = 4
			label.modulate = Color.WHITE
		State.COMPLETED:
			sb.bg_color = accent_color
			sb.border_color = accent_color
			label.modulate = Color.BLACK
			
	add_theme_stylebox_override("normal", sb)
	add_theme_stylebox_override("hover", sb)
	add_theme_stylebox_override("pressed", sb)
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())
