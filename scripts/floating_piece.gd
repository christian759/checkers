extends Control

@export var speed = 50.0

func _process(delta):
	position.y += speed * delta
	rotation += delta * 0.5
	if position.y > get_viewport_rect().size.y + 100:
		position.y = -100
		position.x = randf_range(0, get_viewport_rect().size.x)
