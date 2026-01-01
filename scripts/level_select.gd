extends Control

func _ready():
	$VBoxContainer/TopBar/Back.pressed.connect(_on_back_pressed)
	
	update_level_buttons()

func update_level_buttons():
	var journey_container = $VBoxContainer/ScrollContainer/Journey
	var levels = []
	for child in journey_container.get_children():
		if child is Button:
			levels.append(child)
	
	# Load textures
	var tex_locked = preload("res://assets/ui/level_node_locked.svg")
	var tex_unlocked = preload("res://assets/ui/level_node_unlocked.svg")
	var tex_current = preload("res://assets/ui/level_node_current.svg")
	
	for i in range(levels.size()):
		var level_num = i + 1
		var btn = levels[i]
		
		# Reset button styles for icon usage
		btn.text = "" # No text, number will be in icon or label? 
		# Actually user wants "Numbers must be large and legible".
		# Let's put text ON TOP of the icon.
		btn.text = str(level_num)
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.expand_icon = true
		btn.custom_minimum_size = Vector2(100, 100) # Ensure size
		
		# Button base style - make it flat so only icon shows
		btn.flat = true
		btn.add_theme_font_size_override("font_size", 32)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_color_override("font_pressed_color", Color.WHITE)
		btn.add_theme_color_override("font_hover_color", Color.WHITE)
		
		if btn.has_signal("pressed"):
			if not btn.is_connected("pressed", _on_level_selected):
				# Disconnect all first to avoid dupes if re-run
				# Actually anonymous functions are hard to disconnect.
				# Just assume _ready runs once.
				btn.pressed.connect(func(): _on_level_selected(level_num))
		# Curve pattern: Center -> Right -> Center -> Left -> Center
		var wave = sin(i * 0.8) * 80.0
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		# Adding margin via a wrapper would be better, but we can hack it with pivot for now?
		# No, in VBox we can't easily offset x. 
		# We should wrap them in Control nodes or change margins.
		# Let's use `custom_minimum_size` on a wrapper node? 
		# Simplest for now: Just center them. The "Path" SVG will be background.
		
		if level_num < GameManager.max_unlocked_level:
			# Completed
			btn.icon = tex_unlocked
			btn.disabled = false
			btn.modulate = Color(1, 1, 1)
		elif level_num == GameManager.max_unlocked_level:
			# Current
			btn.icon = tex_current
			btn.disabled = false
			btn.modulate = Color(1, 1, 1)
			# Animate pulse?
		else:
			# Locked
			btn.icon = tex_locked
			btn.disabled = true
			btn.modulate = Color(0.8, 0.8, 0.8)
			btn.text = "" # Hide number on locked? Or keep it.

func _on_back_pressed():
	SceneTransition.change_scene("res://scenes/main_menu.tscn")

func _on_level_selected(level):
	# Set difficulty or load specific map
	print("Selected level ", level)
	GameManager.reset_game()
	GameManager.is_daily_challenge = false
	GameManager.current_level = level
	GameManager.current_mode = GameManager.Mode.PV_AI
	SceneTransition.change_scene("res://scenes/main.tscn")
