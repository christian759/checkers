extends Control

@onready var content_container = $Content
@onready var nav_bar = $BottomNavBar

var sections = {
	0: preload("res://scenes/daily_challenge.tscn"),
	1: preload("res://scenes/board.tscn"), # PvP is the board
	2: preload("res://scenes/mastery.tscn"),
	3: preload("res://scenes/achievement.tscn"),
	4: preload("res://scenes/settings.tscn")
}

var current_section = null

func _ready():
	nav_bar.tab_selected.connect(_on_tab_selected)
	_on_tab_selected(2) # Default to Mastery/Home (Middle Tab)

func _on_tab_selected(index):
	if sections.has(index):
		var old_section = current_section
		var new_section = sections[index].instantiate()
		
		# Prepare new section
		new_section.modulate.a = 0
		content_container.add_child(new_section)
		
		# Centering/Layout
		if new_section is Node2D:
			# Dynamic board centering
			var screen_size = get_viewport_rect().size
			# Board width is 95% of screen width (as set in board.gd)
			var board_width = screen_size.x * 0.95
			new_section.position = Vector2((screen_size.x - board_width) / 2.0, (content_container.size.y - board_width) / 2.0)
		elif new_section is Control:
			new_section.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		
		# Smooth Transition
		var tween = create_tween().set_parallel(true)
		
		if old_section:
			tween.tween_property(old_section, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_SINE)
			# Removing old section after fade
			var clear_tween = create_tween()
			clear_tween.tween_interval(0.25)
			clear_tween.tween_callback(old_section.queue_free)
		
		var in_tween = create_tween()
		in_tween.tween_interval(0.1)
		in_tween.tween_property(new_section, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
		
		current_section = new_section
