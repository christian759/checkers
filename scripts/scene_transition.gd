extends CanvasLayer

@onready var color_rect = $ColorRect

func _ready():
	color_rect.position.x = -get_viewport().size.x * 1.5
	color_rect.rotation_degrees = 15
	hide()

func change_scene(target_path: String):
	show()
	var viewport_w = get_viewport().size.x
	
	# Sweep In
	var tween = create_tween()
	tween.tween_property(color_rect, "position:x", 0.0, 0.4).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	get_tree().change_scene_to_file(target_path)
	
	# Sweep Out
	tween = create_tween()
	tween.tween_property(color_rect, "position:x", viewport_w * 1.5, 0.4).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	
	hide()
	color_rect.position.x = -get_viewport().size.x * 1.5
