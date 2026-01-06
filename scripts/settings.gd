extends Control

@onready var forced_jumps_btn = %ForcedJumpsBtn
@onready var movement_btn = %MovementBtn
@onready var sound_btn = %SoundBtn
@onready var vibration_btn = %VibrationBtn

func _ready():
	_update_ui()
	
	forced_jumps_btn.pressed.connect(func():
		GameManager.forced_jumps = !GameManager.forced_jumps
		_update_ui()
		GameManager.save_data()
	)
	
	movement_btn.pressed.connect(func():
		GameManager.movement_mode = "straight" if GameManager.movement_mode == "diagonal" else "diagonal"
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
	_set_toggle_state(movement_btn, GameManager.movement_mode == "straight")
	_set_toggle_state(sound_btn, GameManager.sound_enabled)
	_set_toggle_state(vibration_btn, GameManager.vibration_enabled)
	
	# Update text for movement mode specifically
	var mode_label = movement_btn.get_node_or_null("Label")
	if mode_label:
		mode_label.text = "MOVEMENT: " + GameManager.movement_mode.to_upper()

func _set_toggle_state(btn, is_on):
	var bubble = btn.get_node_or_null("Bubble")
	if not bubble: return
	
	var target_x = 6.0 if !is_on else btn.size.x - bubble.size.x - 6.0
	var target_color = GameManager.FOREST if is_on else GameManager.FOREST.lerp(Color.WHITE, 0.6)
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_property(bubble, "position:x", target_x, 0.4)
	tween.tween_property(bubble, "modulate", Color.WHITE if is_on else Color("#ffffff88"), 0.3)
	
	var bg = btn.get_node_or_null("Background")
	if bg:
		tween.tween_property(bg, "modulate", target_color if is_on else Color.WHITE, 0.3)
