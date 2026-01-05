extends Control

@onready var logo_container = %LogoContainer
@onready var char_box = %CharBox
@onready var sub_label = %SubLabel

var chars = []

func _ready():
	# Initial state
	if logo_container:
		logo_container.modulate.a = 0
	if sub_label:
		sub_label.modulate.a = 0
		sub_label.position.y += 20
	
	# Create characters for "JIGGY"
	var word = "JIGGY"
	for c in word:
		var lbl = Label.new()
		lbl.text = c
		lbl.add_theme_font_size_override("font_size", 100)
		lbl.add_theme_color_override("font_color", Color("#27AE60"))
		lbl.pivot_offset = Vector2(35, 60)
		char_box.add_child(lbl)
		chars.append(lbl)
		
		# Set initial position for bounce
		lbl.position.y -= 100
		lbl.modulate.a = 0
	
	_animate_splash()

func _process(delta):
	# Subtle floating idle for characters
	var time = Time.get_ticks_msec() / 1000.0
	for i in range(chars.size()):
		var lbl = chars[i]
		var offset = i * 0.5
		lbl.rotation = sin(time * 2.0 + offset) * 0.05
		lbl.scale = Vector2(1, 1) + Vector2(1, 1) * sin(time * 3.0 + offset) * 0.02

func _animate_splash():
	var tween = create_tween().set_parallel(true)
	
	if logo_container:
		tween.tween_property(logo_container, "modulate:a", 1.0, 0.5)
	
	# Elastic Bounce Entrance
	for i in range(chars.size()):
		var lbl = chars[i]
		var char_tween = create_tween().set_parallel(true)
		char_tween.tween_interval(i * 0.1)
		char_tween.tween_property(lbl, "position:y", 0.0, 1.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		char_tween.tween_property(lbl, "modulate:a", 1.0, 0.3)
	
	if sub_label:
		var s_tween = create_tween()
		s_tween.tween_interval(1.2)
		s_tween.tween_property(sub_label, "modulate:a", 1.0, 0.8)
		s_tween.tween_property(sub_label, "position:y", sub_label.position.y - 20, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	get_tree().create_timer(4.0).timeout.connect(_on_timeout)

func _on_timeout():
	var fade = create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 0.8)
	fade.finished.connect(func():
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	)
