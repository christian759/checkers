extends Control

@onready var logo_container = %LogoContainer
@onready var main_label = %MainLabel
@onready var shadow_label = %ShadowLabel
@onready var sub_label = %SubLabel

func _ready():
	# Force white background
	var bg = get_node_or_null("Bg")
	if bg: bg.color = Color.WHITE
	
	# Initial state
	if logo_container:
		logo_container.modulate.a = 0
		logo_container.scale = Vector2(0.8, 0.8)
	if main_label:
		# Use offset_top as the baseline for centered labels
		main_label.position.y += 10
	if sub_label:
		sub_label.modulate.a = 0
		sub_label.position.y += 10
	
	_animate_splash()

func _process(delta):
	# Add a subtle "jiggy" hover effect to the main text
	if not main_label: return
	
	var time = Time.get_ticks_msec() / 1000.0
	var hover = sin(time * 3.5) * 6.0
	main_label.position.y = (logo_container.size.y / 2.0 - main_label.size.y / 2.0) + hover
	main_label.rotation = sin(time * 2.2) * 0.03
	
	if shadow_label:
		shadow_label.position = main_label.position + Vector2(4, 4)
		shadow_label.rotation = main_label.rotation

func _animate_splash():
	var tween = create_tween().set_parallel(true)
	
	# Logo Fade & Scale
	if logo_container:
		tween.tween_property(logo_container, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE)
		tween.tween_property(logo_container, "scale", Vector2(1.0, 1.0), 1.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Main Text Entrance
	if main_label:
		var text_tween = create_tween()
		text_tween.tween_interval(0.2)
		text_tween.tween_property(main_label, "position:y", -65.0, 0.6).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	# Sub Text Fade
	if sub_label:
		var sub_tween = create_tween()
		sub_tween.tween_interval(0.6)
		sub_tween.tween_property(sub_label, "modulate:a", 1.0, 0.4)
		sub_tween.tween_property(sub_label, "position:y", sub_label.position.y - 10, 0.4).set_trans(Tween.TRANS_SINE)
	
	# Transition to Main Menu
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(_on_timeout)

func _on_timeout():
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	fade_tween.finished.connect(func():
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	)
