extends Node2D

@export var rot_speed = 0.5
@export var speed = 100.0
var time = 0.0
var base_mod = 0.15

func _ready():
	# Vary base modulation for depth effect
	base_mod = randf_range(0.05, 0.25)
	modulate.a = base_mod
	time = randf() * 10.0
	
	# Link scale to opacity for extra depth feel
	var scale_factor = lerp(0.5, 1.2, (base_mod - 0.05) / 0.2)
	scale = Vector2(scale_factor, scale_factor)

func _process(delta):
	time += delta
	position.y += speed * delta
	rotation += delta * rot_speed
	
	# Soft pulse
	modulate.a = base_mod + sin(time * 1.5) * 0.03
	
	if position.y > get_viewport_rect().size.y + 200:
		position.y = -200
		position.x = randf_range(0, get_viewport_rect().size.x)
