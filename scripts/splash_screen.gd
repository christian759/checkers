extends Control

func _ready():
	$ColorRect.color = Color("#FFFFFF") # Pure White
	$CenterContainer/Label.modulate = Color("#2ecc71") # Emerald Green
	$CenterContainer/Label.modulate.a = 0
	$CenterContainer/Label.scale = Vector2(0.5, 0.5) # Initial small scale
	$CenterContainer/Label.pivot_offset = $CenterContainer/Label.size / 2
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property($CenterContainer/Label, "modulate:a", 1.0, 1.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property($CenterContainer/Label, "scale", Vector2(1.0, 1.0), 1.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	var flow_tween = create_tween()
	flow_tween.tween_interval(2.5)
	flow_tween.tween_property($CenterContainer/Label, "modulate:a", 0.0, 0.5)
	flow_tween.finished.connect(_on_tween_finished)

func _on_tween_finished():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
