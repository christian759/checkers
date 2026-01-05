extends Button

@onready var label = $Label
@onready var lock_icon = $LockIcon

enum State {LOCKED, CURRENT, COMPLETED}
var level_num_stored = 1
var state_stored = State.LOCKED

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)

func setup(level_num: int, state: State, accent_color: Color):
	level_num_stored = level_num
	state_stored = state
	text = ""
	
	label.text = str(level_num)
	label.visible = (state != State.LOCKED)
	lock_icon.visible = (state == State.LOCKED)
	
	# Clear styles for custom drawing
	add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	
	_update_style(accent_color)

func _update_style(accent_color: Color):
	if label:
		if state_stored == State.LOCKED:
			label.add_theme_color_override("font_color", Color("#1B4332", 0.1))
		elif state_stored == State.COMPLETED:
			label.add_theme_color_override("font_color", Color.WHITE)
		else:
			label.add_theme_color_override("font_color", accent_color)
	
	if lock_icon:
		lock_icon.modulate = Color("#1B4332", 0.1)
	
	queue_redraw()

func _draw():
	var center = size / 2
	var radius = min(size.x, size.y) * 0.4
	
	match state_stored:
		State.LOCKED:
			draw_arc(center, radius, 0, TAU, 32, Color("#1B4332", 0.1), 2.0)
		State.CURRENT:
			# Bold ring for active
			draw_arc(center, radius, 0, TAU, 32, Color("#1B4332"), 4.0)
			draw_circle(center, radius * 0.4, Color("#1B4332", 0.1))
		State.COMPLETED:
			# Solid bold circle
			draw_circle(center, radius, Color("#1B4332"))

func _on_mouse_entered():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2).set_trans(Tween.TRANS_SINE)

func _on_mouse_exited():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE)

func _on_pressed():
	if state_stored != State.LOCKED:
		GameManager.start_mastery_level(level_num_stored)
