extends Control

@onready var forced_jumps_btn = $VBox/ForcedJumps/Button
@onready var movement_btn = $VBox/Movement/Button

func _ready():
	_update_ui()
	
	$TopBar/Back.pressed.connect(_on_back_pressed)
	forced_jumps_btn.pressed.connect(_on_forced_jumps_toggled)
	movement_btn.pressed.connect(_on_movement_toggled)

func _update_ui():
	forced_jumps_btn.text = "ON" if GameManager.forced_jumps else "OFF"
	movement_btn.text = GameManager.movement_mode.to_upper()

func _on_forced_jumps_toggled():
	GameManager.forced_jumps = !GameManager.forced_jumps
	_update_ui()

func _on_movement_toggled():
	if GameManager.movement_mode == "diagonal":
		GameManager.movement_mode = "straight"
	else:
		GameManager.movement_mode = "diagonal"
	_update_ui()

func _on_back_pressed():
	SceneTransition.change_scene("res://scenes/map_menu.tscn")
