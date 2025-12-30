extends Control

func _ready():
	$VBoxContainer/Back.pressed.connect(_on_back_pressed)
	# Connect level buttons loop or manual
	$VBoxContainer/GridContainer/Level1.pressed.connect(func(): _on_level_selected(1))
	$VBoxContainer/GridContainer/Level2.pressed.connect(func(): _on_level_selected(2))
	$VBoxContainer/GridContainer/Level3.pressed.connect(func(): _on_level_selected(3))

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_level_selected(level):
	# Set difficulty or load specific map
	print("Selected level ", level)
	GameManager.current_mode = GameManager.Mode.PV_AI
	get_tree().change_scene_to_file("res://scenes/main.tscn")
