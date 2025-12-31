@export var rot_speed = 0.5
var time = 0.0
var base_mod = 0.2

func _ready():
	base_mod = randf_range(0.1, 0.3)
	modulate.a = base_mod
	time = randf() * 10.0

func _process(delta):
	time += delta
	position.y += speed * delta
	rotation += delta * rot_speed
	
	# Soft pulse
	modulate.a = base_mod + sin(time * 2.0) * 0.05
	
	if position.y > get_viewport_rect().size.y + 100:
		position.y = -100
		position.x = randf_range(0, get_viewport_rect().size.x)
