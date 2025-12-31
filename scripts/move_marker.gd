extends Node2D

func _ready():
	modulate = Color(1, 1, 1, 0.7)
	var tween = create_tween().set_loops()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5)

func _draw():
	draw_circle(Vector2.ZERO, 10, Color.WHITE)
