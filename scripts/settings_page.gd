extends Control

@onready var sound_toggle = %SoundToggle
@onready var music_toggle = %MusicToggle
@onready var forced_jumps_toggle = %ForcedJumpsToggle
@onready var move_hints_toggle = %MoveHintsToggle

func _ready():
	_load_settings()
	
	sound_toggle.toggled.connect(_on_sound_toggled)
	music_toggle.toggled.connect(_on_music_toggled)
	forced_jumps_toggle.toggled.connect(_on_forced_jumps_toggled)
	move_hints_toggle.toggled.connect(_on_move_hints_toggled)

func _load_settings():
	# In a real app, these would come from a config file or GameManager
	# For now, we'll sync with GameManager if it has them, or use defaults
	if "forced_jumps" in GameManager:
		forced_jumps_toggle.button_pressed = GameManager.forced_jumps
	
	# Assuming other settings might be added to GameManager later
	sound_toggle.button_pressed = true
	music_toggle.button_pressed = true
	move_hints_toggle.button_pressed = true

func _on_sound_toggled(_button_pressed):
	# AchievementManager or AudioManager call here
	pass

func _on_music_toggled(_button_pressed):
	# AudioManager call here
	pass

func _on_forced_jumps_toggled(button_pressed):
	GameManager.forced_jumps = button_pressed

func _on_move_hints_toggled(_button_pressed):
	# Logic to show/hide move markers
	pass
