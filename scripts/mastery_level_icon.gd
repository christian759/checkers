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
	
	var sb = StyleBoxFlat.new()
	sb.set_corner_radius_all(100) # Pure Circle
	sb.anti_aliasing = true
	
	match state:
		State.LOCKED:
			sb.bg_color = Color("#EAECEE")
			sb.set_border_width_all(1)
			sb.border_color = Color("#D5D8DC")
			lock_icon.modulate = Color("#ABB2B9")
		State.CURRENT:
			sb.bg_color = Color.WHITE
			sb.set_border_width_all(3)
			sb.border_color = Color("#2ECC71")
			sb.shadow_color = Color("#2ECC71", 0.4)
			sb.shadow_size = 12
			label.add_theme_color_override("font_color", Color("#2ECC71"))
			_start_pulse_animation()
		State.COMPLETED:
			sb.bg_color = Color("#2ECC71")
			sb.set_border_width_all(0)
			sb.shadow_color = Color("#27AE60", 0.3)
			sb.shadow_size = 8
			label.add_theme_color_override("font_color", Color.WHITE)
			
	add_theme_stylebox_override("normal", sb)
	add_theme_stylebox_override("hover", sb)
	add_theme_stylebox_override("pressed", sb)
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _on_mouse_entered():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if state_stored == State.COMPLETED:
		modulate = Color(1.2, 1.2, 1.2)

func _on_mouse_exited():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE)
	modulate = Color.WHITE

func _on_pressed():
	# Allow playing if CURRENT or COMPLETED
	if state_stored != State.LOCKED:
		GameManager.start_mastery_level(level_num_stored)

func _start_pulse_animation():
	var tween = create_tween().set_loops()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.8).set_trans(Tween.TRANS_SINE)
