extends Control

@onready var bg = $Bg
@onready var logo_container = %LogoContainer
@onready var char_box = %CharBox
@onready var sub_label = %SubLabel

var chars = []

func _ready():
	# Emerald Minimalist Theme
	bg.color = Color.WHITE
	
	if logo_container:
		logo_container.modulate.a = 0
	if sub_label:
		sub_label.modulate.a = 0
		sub_label.add_theme_color_override("font_color", Color("#1B4332", 0.4))
	
	# Create characters for "CHECKERS"
	var word = "CHECKERS"
	for c in word:
		var lbl = Label.new()
		lbl.text = c
		lbl.add_theme_font_size_override("font_size", 80) # Larger
		lbl.add_theme_color_override("font_color", Color("#1B4332"))
		lbl.pivot_offset = Vector2(30, 45)
		char_box.add_child(lbl)
		chars.append(lbl)
		lbl.modulate.a = 0
	
	if sub_label:
		sub_label.text = "BY JIGGY"
		sub_label.add_theme_font_size_override("font_size", 28)
		sub_label.add_theme_constant_override("line_spacing", 4)
	
	_animate_splash()

func _animate_splash():
	var tween = create_tween().set_parallel(true)
	
	if logo_container:
		tween.tween_property(logo_container, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE)
		tween.tween_property(logo_container, "position:y", logo_container.position.y - 10, 2.0).set_trans(Tween.TRANS_SINE)
	
	for i in range(chars.size()):
		var lbl = chars[i]
		var delay = i * 0.1
		var char_tween = create_tween()
		char_tween.tween_interval(delay)
		char_tween.tween_property(lbl, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE)
	
	if sub_label:
		var s_tween = create_tween()
		s_tween.tween_interval(1.5)
		s_tween.tween_property(sub_label, "modulate:a", 1.0, 2.0).set_trans(Tween.TRANS_SINE)

	get_tree().create_timer(4.0).timeout.connect(_on_timeout)

func _on_timeout():
	var fade = create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 1.0)
	fade.finished.connect(func():
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	)
