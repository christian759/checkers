extends CanvasLayer

@onready var color_rect = $ColorRect

func _ready():
	color_rect.modulate.a = 0
	hide()

func change_scene(target_path: String):
	show()
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, 0.3)
	await tween.finished
	
	get_tree().change_scene_to_file(target_path)
	
	tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, 0.3)
	await tween.finished
	hide()
