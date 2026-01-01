extends Control

signal level_pressed(number)

@onready var title_label = $VBox/Title
@onready var level_container = $VBox/Levels

func setup(stage_num, sub_levels_data):
	title_label.text = "STAGE " + str(stage_num)
	
	for i in range(3):
		var btn = level_container.get_child(i)
		var level_num = (stage_num - 1) * 3 + (i + 1)
		btn.text = str(i + 1)
		
		# In a real app, we'd check GameManager for stars/unlocked here
		# For now, just connect the signal
		if not btn.is_connected("pressed", _on_level_btn_pressed):
			btn.pressed.connect(_on_level_btn_pressed.bind(level_num))

func _on_level_btn_pressed(num):
	level_pressed.emit(num)
