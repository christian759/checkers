extends Control

func _ready():
	$ColorRect.color = Color("#f9f9f9")
	$CenterContainer/Label.modulate = Color("#2ecc71")
	$CenterContainer/Label.modulate.a = 0
	$CenterContainer/Label.scale = Vector2(0.8, 0.8)
	$CenterContainer/Label.pivot_offset = $CenterContainer/Label.size / 2
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property($CenterContainer/Label, "modulate:a", 1.0, 1.2).set_trans(Tween.TRANS_SINE)
	tween.tween_property($CenterContainer/Label, "scale", Vector2(1.0, 1.0), 1.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	var fade_out = create_tween().set_delay(2.5)
	fade_out.tween_property($CenterContainer/Label, "modulate:a", 0.0, 0.8).set_trans(Tween.TRANS_SINE)
	fade_out.finished.connect(_on_tween_finished)

func _on_tween_finished():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
