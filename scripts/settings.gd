extends Control

@onready var forced_jumps_btn = %ForcedJumpsBtn
@onready var sound_btn = %SoundBtn
@onready var vibration_btn = %VibrationBtn

func _ready():
	_update_ui()
	
	forced_jumps_btn.pressed.connect(func():
		GameManager.forced_jumps = !GameManager.forced_jumps
		_update_ui()
		GameManager.save_data()
	)
	
	sound_btn.pressed.connect(func():
		GameManager.sound_enabled = !GameManager.sound_enabled
		_update_ui()
		GameManager.save_data()
	)
	
	vibration_btn.pressed.connect(func():
		GameManager.vibration_enabled = !GameManager.vibration_enabled
		_update_ui()
		GameManager.save_data()
	)

func _update_ui():
	_set_toggle_state(forced_jumps_btn, GameManager.forced_jumps)
	_set_toggle_state(sound_btn, GameManager.sound_enabled)
	_set_toggle_state(vibration_btn, GameManager.vibration_enabled)

func _set_toggle_state(btn, is_on):
	# Emerald green for ON, light gray for OFF
	if is_on:
		btn.modulate = Color(0.063, 0.725, 0.506, 1.0) # Emerald green
		btn.text = "ON"
		btn.add_theme_color_override("font_color", Color.WHITE)
	else:
		btn.modulate = Color(0.9, 0.9, 0.9, 1.0) # Light gray
		btn.text = "OFF"
		btn.add_theme_color_override("font_color", Color(0.105882, 0.262745, 0.196078, 0.6))
