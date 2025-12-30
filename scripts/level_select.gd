extends Control

func _ready():
	$VBoxContainer/Back.pressed.connect(_on_back_pressed)
	
	update_level_buttons()

func update_level_buttons():
	var btn1 = $VBoxContainer/GridContainer/Level1
	var btn2 = $VBoxContainer/GridContainer/Level2
	var btn3 = $VBoxContainer/GridContainer/Level3
	var btn4 = $VBoxContainer/GridContainer/Level4
	var btn5 = $VBoxContainer/GridContainer/Level5
	
	btn1.pressed.connect(func(): _on_level_selected(1))
	btn2.pressed.connect(func(): _on_level_selected(2))
	btn3.pressed.connect(func(): _on_level_selected(3))
	btn4.pressed.connect(func(): _on_level_selected(4))
	btn5.pressed.connect(func(): _on_level_selected(5))
	
	btn2.disabled = GameManager.max_unlocked_level < 2
	btn3.disabled = GameManager.max_unlocked_level < 3
	btn4.disabled = GameManager.max_unlocked_level < 4
	btn5.disabled = GameManager.max_unlocked_level < 5

func _on_back_pressed():
	SceneTransition.change_scene("res://scenes/main_menu.tscn")

func _on_level_selected(level):
	# Set difficulty or load specific map
	print("Selected level ", level)
	GameManager.current_level = level
	GameManager.current_mode = GameManager.Mode.PV_AI
	SceneTransition.change_scene("res://scenes/main.tscn")
