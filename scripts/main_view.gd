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
	_on_tab_selected(1) # Default to Board/PvP

func _on_tab_selected(index):
	if current_section:
		current_section.queue_free()
	
	if sections.has(index):
		var new_section = sections[index].instantiate()
		content_container.add_child(new_section)
		current_section = new_section
		
		# Center Node2D content (like the Board)
		if new_section is Node2D:
			# Board is approx 640x640
			var board_size = Vector2(640, 640)
			new_section.position = (content_container.size - board_size) / 2
		elif new_section is Control:
			new_section.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
