extends Node2D

func _ready():
	modulate.a = 0.6
	# Gentle slow breath, no aggressive pulse
	var tween = create_tween().set_loops()
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 1.0).set_trans(Tween.TRANS_SINE)

func _draw():
	# Simple Clean Ring
	draw_arc(Vector2.ZERO, 15, 0, TAU, 32, Color.WHITE, 3.0, true)
	draw_arc(Vector2.ZERO, 15, 0, TAU, 32, Color("#1B4332", 0.2), 5.0, true) # Soft forest border
