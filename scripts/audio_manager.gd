extends Node

# Dictionary to hold streams
var sounds = {}

func _ready():
	load_sound("move", "res://assets/sounds/move.wav")
	load_sound("capture", "res://assets/sounds/capture.wav")
	load_sound("win", "res://assets/sounds/win.wav")

func load_sound(name, path):
	if FileAccess.file_exists(path):
		sounds[name] = load(path)

func play_sound(name):
	if sounds.has(name):
		var asp = AudioStreamPlayer.new()
		asp.stream = sounds[name]
		asp.bus = "SFX"
		add_child(asp)
		asp.play()
		asp.finished.connect(asp.queue_free)

func play_music(path):
	# Music logic here
	pass
