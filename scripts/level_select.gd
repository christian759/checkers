extends Control

func _ready():
	$VBoxContainer/TopBar/Back.pressed.connect(_on_back_pressed)
	
	update_level_buttons()

func update_level_buttons():
	var journey_container = $VBoxContainer/ScrollContainer/Journey
	var levels = []
	for child in journey_container.get_children():
		if child is Button:
			levels.append(child)
	
	for i in range(levels.size()):
		var level_num = i + 1
		var btn = levels[i]
		if btn.has_signal("pressed"):
			btn.pressed.connect(func(): _on_level_selected(level_num))
		
		if level_num > GameManager.max_unlocked_level:
			btn.disabled = true
			btn.modulate = Color(0.5, 0.5, 0.5) # Dim locked levels
		else:
			btn.disabled = false
			btn.modulate = Color(1, 1, 1)

func _on_back_pressed():
	SceneTransition.change_scene("res://scenes/main_menu.tscn")

func _on_level_selected(level):
	# Set difficulty or load specific map
	print("Selected level ", level)
	GameManager.current_level = level
	GameManager.current_mode = GameManager.Mode.PV_AI
	SceneTransition.change_scene("res://scenes/main.tscn")
