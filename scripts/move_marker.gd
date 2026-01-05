extends Node2D

func _ready():
	modulate.a = 0.9
	var tween = create_tween().set_loops()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.6).set_trans(Tween.TRANS_SINE)

func _draw():
	# Draw glow/shadow ring
	draw_arc(Vector2.ZERO, 15, 0, TAU, 32, Color(0, 0, 0, 0.2), 4.0, true)
	# Draw main ring
	draw_arc(Vector2.ZERO, 15, 0, TAU, 32, Color.WHITE, 2.5, true)
	# Draw pulsing center
	draw_circle(Vector2.ZERO, 6, Color.WHITE)
