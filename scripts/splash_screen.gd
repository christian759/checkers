extends Control

func _ready():
	$ColorRect.color = Color("#0f0f13")
	$CenterContainer/Label.modulate.a = 0
	
	var tween = create_tween()
	tween.tween_property($CenterContainer/Label, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(1.5)
	tween.tween_property($CenterContainer/Label, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(_on_tween_finished)

func _on_tween_finished():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
