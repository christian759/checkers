extends Control

@onready var texture_rect = $TextureRect
@onready var label = $TextureRect/Label
@onready var button = $Button # Keeping button for interaction but making it invisible? 
# Actually, let's replace Button with TextureButton logic or just click detection.
# Simplest: TextureRect for visual, transparent Button for click.

func set_level_data(level_id, locked):
	# Using native StyleBoxFlat for modern, asset-free circles
	var sb = StyleBoxFlat.new()
	sb.set_corner_radius_all(80) # Circle shape
	
	if locked:
		sb.bg_color = Color("#cccccc")
		sb.border_width_bottom = 4
		sb.border_color = Color("#aaaaaa")
		$TextureRect/Label.add_theme_color_override("font_color", Color("#888888"))
		$Button.disabled = true
	else:
		sb.bg_color = Color("#8ec442")
		sb.border_width_bottom = 8
		sb.border_color = Color("#549b0e")
		$TextureRect/Label.add_theme_color_override("font_color", Color.WHITE)
		$Button.disabled = false
	
	# Assuming Background is a Panel, which we'll need to update in the .tscn
	# For now, let's override the Button style itself for simplicity
	$Button.add_theme_stylebox_override("normal", sb)
	$Button.add_theme_stylebox_override("disabled", sb)
	$TextureRect.visible = false # Hide old texture container
	$Button.text = str(level_id) # Put number on button
	$Button.add_theme_font_size_override("font_size", 40)
