extends Control

@onready var texture_rect = $TextureRect
@onready var label = $TextureRect/Label
@onready var button = $Button # Keeping button for interaction but making it invisible? 
# Actually, let's replace Button with TextureButton logic or just click detection.
# Simplest: TextureRect for visual, transparent Button for click.

func set_level_data(level_id, locked):
	$Button.text = "" # Clear text from button, we use custom label
	$TextureRect/Label.text = str(level_id)
	
	if locked:
		$TextureRect.texture = load("res://assets/ui/node_locked.svg")
		$TextureRect/Label.visible = false
		$Button.disabled = true
	else:
		$TextureRect.texture = load("res://assets/ui/node_unlocked.svg")
		$TextureRect/Label.visible = true
		$TextureRect/Label.add_theme_color_override("font_color", Color.WHITE)
		$TextureRect/Label.add_theme_color_override("font_shadow_color", Color(0,0,0,0.3))
		$Button.disabled = false
