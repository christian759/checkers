extends Button

@onready var label = $Label

enum State {LOCKED, CURRENT, COMPLETED}

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup(level_num: int, state: State, accent_color: Color):
	text = ""
	label.text = str(level_num)
	
	var sb = StyleBoxFlat.new()
	sb.set_corner_radius_all(100)
	sb.set_border_width_all(2)
	sb.anti_aliasing = true
	
	match state:
		State.LOCKED:
			sb.bg_color = Color(0.1, 0.1, 0.1, 0.6)
			sb.border_color = Color(0.2, 0.2, 0.2, 0.8)
			label.modulate = Color(0.4, 0.4, 0.4)
		State.CURRENT:
			sb.bg_color = accent_color.darkened(0.7)
			sb.border_color = accent_color
			sb.shadow_color = accent_color.lightened(0.2)
			sb.shadow_size = 8
			label.modulate = Color.WHITE
			_start_pulse_animation(accent_color)
		State.COMPLETED:
			sb.bg_color = accent_color
			sb.border_color = accent_color
			label.modulate = Color.BLACK
			
	add_theme_stylebox_override("normal", sb)
	add_theme_stylebox_override("hover", sb)
	add_theme_stylebox_override("pressed", sb)
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _on_mouse_entered():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	modulate.v = 1.2

func _on_mouse_exited():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_SINE)
	modulate.v = 1.0

func _start_pulse_animation(color: Color):
	var tween = create_tween().set_loops()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.8).set_trans(Tween.TRANS_SINE)
