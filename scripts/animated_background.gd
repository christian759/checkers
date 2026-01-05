extends Control

@onready var bg1 = $BG1
@onready var bg2 = $BG2

func _ready():
	_animate_bg()

func _animate_bg():
	var tween = create_tween().set_loops().set_parallel(true)
	
	# Rotate and scale subtly
	tween.tween_property(bg1, "rotation_degrees", 360.0, 60.0)
	tween.tween_property(bg2, "rotation_degrees", -360.0, 45.0)
	
	var pulse = create_tween().set_loops()
	pulse.tween_property(bg1, "scale", Vector2(1.2, 1.2), 10.0).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(bg1, "scale", Vector2(1.0, 1.0), 10.0).set_trans(Tween.TRANS_SINE)
