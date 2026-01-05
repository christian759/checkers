extends Control

@onready var logo_container = %LogoContainer
@onready var main_label = %MainLabel
@onready var sub_label = %SubLabel

func _ready():
	# Initial state
	if logo_container:
		logo_container.modulate.a = 0
		logo_container.scale = Vector2(0.9, 0.9)
	if main_label:
		main_label.modulate.a = 0
		main_label.position.y += 30
	if sub_label:
		sub_label.modulate.a = 0
	
	_animate_splash()

func _process(delta):
	# Gentle floating wave animation
	if not main_label: return
	
	var time = Time.get_ticks_msec() / 1000.0
	main_label.position.y = -65 + sin(time * 2.0) * 10.0
	main_label.scale = Vector2(1, 1) + Vector2(1, 1) * sin(time * 1.5) * 0.02

func _animate_splash():
	var tween = create_tween().set_parallel(true)
	
	# Entrance Animation
	if logo_container:
		tween.tween_property(logo_container, "modulate:a", 1.0, 1.2).set_trans(Tween.TRANS_SINE)
		tween.tween_property(logo_container, "scale", Vector2(1.0, 1.0), 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	if main_label:
		var m_tween = create_tween().set_parallel(true)
		m_tween.tween_interval(0.3)
		m_tween.tween_property(main_label, "modulate:a", 1.0, 1.0)
		m_tween.tween_property(main_label, "position:y", -65.0, 1.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	if sub_label:
		var s_tween = create_tween()
		s_tween.tween_interval(0.8)
		s_tween.tween_property(sub_label, "modulate:a", 1.0, 0.8)

	# Transition to Main
	get_tree().create_timer(4.0).timeout.connect(_on_timeout)

func _on_timeout():
	var fade = create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 0.8)
	fade.finished.connect(func():
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	)
