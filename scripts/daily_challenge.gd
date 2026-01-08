extends Control

@onready var streak_val = %Value
@onready var calendar_grid = %CalendarGrid
@onready var puzzle_title = $ScrollContainer/VBox/MissionsSection/Card/VBox/VBox/PuzzleTitle
@onready var puzzle_desc = $ScrollContainer/VBox/MissionsSection/Card/VBox/PuzzleDesc
@onready var solve_button = $ScrollContainer/VBox/MissionsSection/Card/VBox/SolveButton

var current_puzzle = null

func _ready():
	_setup_calendar()
	_refresh_ui()
	solve_button.pressed.connect(_on_solve_pressed)

func _refresh_ui():
	streak_val.text = str(GameManager.daily_streak)
	
	current_puzzle = _get_today_puzzle()
	puzzle_title.text = current_puzzle.title
	puzzle_desc.text = current_puzzle.desc
	
	var today = Time.get_date_string_from_system()
	if GameManager.last_daily_date == today:
		solve_button.disabled = true
		solve_button.text = "COMPLETED"
		puzzle_title.text = "Training Complete"
		puzzle_desc.text = "Great work! You've mastered today's tactical mission. Return tomorrow for your next challenge."

func _setup_calendar():
	# Clear existing
	for child in calendar_grid.get_children():
		child.queue_free()
	
	# Create 7 days (current week)
	var today_dict = Time.get_date_dict_from_system()
	var day_of_week = _get_day_of_week(today_dict) # 0 = Sun, 6 = Sat (Simplified)
	
	# Let's just show the last 7 days including today
	for i in range(7):
		var day_panel = _create_day_node(6 - i)
		calendar_grid.add_child(day_panel)
		# Move today to the end or start? Usually calendar flows. 
		# Let's just show 7 slots and mark completed ones.

func _create_day_node(days_ago: int) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(40, 50)
	
	var day_date = _get_date_string_offset(-days_ago)
	var is_today = days_ago == 0
	var is_completed = day_date in GameManager.completed_dailies
	
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.bg_color = Color("#063314") if is_completed else (Color("#f0f5f0") if is_today else Color.WHITE)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color("#00ff88") if is_today else Color("#eeeeee")
	
	panel.add_theme_stylebox_override("panel", style)
	
	var label = Label.new()
	label.text = day_date.split("-")[2] # Just the day number
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color.WHITE if is_completed else Color("#666666"))
	panel.add_child(label)
	
	if is_completed:
		var check = Label.new()
		check.text = "✓"
		check.add_theme_font_size_override("font_size", 10)
		check.add_theme_color_override("font_color", Color("#00ff88"))
		check.position = Vector2(25, 5)
		panel.add_child(check)
		
	return panel

func _get_date_string_offset(offset: int) -> String:
	var unix = Time.get_unix_time_from_system() + (offset * 86400)
	var dict = Time.get_date_dict_from_unix_time(unix)
	return "%04d-%02d-%02d" % [dict.year, dict.month, dict.day]

func _get_day_of_week(dict) -> int:
	# Simplified zeller or similar not needed for basic display
	return 0

func _get_today_puzzle():
	var date_dict = Time.get_date_dict_from_system()
	var day_index = date_dict.day + date_dict.month * 31
	var puzzle_index = day_index % GameManager.puzzles.size()
	return GameManager.puzzles[puzzle_index]

func _on_solve_pressed():
	GameManager.is_daily_challenge = true
	GameManager.current_puzzle_id = current_puzzle.id
	get_tree().change_scene_to_file("res://scenes/board.tscn")
