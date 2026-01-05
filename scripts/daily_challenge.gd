extends Control

@onready var month_label = %MonthLabel
@onready var streak_label = %StreakLabel
@onready var grid = %Grid
@onready var task_date_label = %TaskDate
@onready var task_title = %TaskTitle
@onready var task_desc = %TaskDesc
@onready var solve_button = %SolveButton

var current_view_date = Time.get_date_dict_from_system()
var selected_date_str = ""
var selected_puzzle = null

func _ready():
	selected_date_str = Time.get_date_string_from_system()
	_refresh_calendar()
	_select_day(selected_date_str)
	solve_button.pressed.connect(_on_solve_pressed)

func _refresh_calendar():
	# Clear grid
	for child in grid.get_children():
		child.queue_free()
	
	var today_str = Time.get_date_string_from_system()
	var today_dict = Time.get_date_dict_from_system()
	
	month_label.text = _get_month_name(today_dict.month).upper() + " " + str(today_dict.year)
	streak_label.text = "🔥 " + str(GameManager.daily_streak) + " STREAK"
	
	# Simple 31-day month for MVP (robust logic would calculate days in month)
	var days_in_month = 31
	if today_dict.month == 2: days_in_month = 28
	elif today_dict.month in [4, 6, 9, 11]: days_in_month = 30
	
	for day in range(1, days_in_month + 1):
		var date_str = "%04d-%02d-%02d" % [today_dict.year, today_dict.month, day]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(45, 45)
		btn.text = str(day)
		btn.add_theme_font_size_override("font_size", 16)
		
		# Styles
		var sb = StyleBoxFlat.new()
		sb.set_corner_radius_all(10)
		
		var is_past = day < today_dict.day
		var is_today = day == today_dict.day
		var is_future = day > today_dict.day
		var is_done = date_str in GameManager.completed_daily_dates
		
		if is_today:
			sb.bg_color = Color("#27AE60") # Emerald
			btn.add_theme_color_override("font_color", Color.WHITE)
		elif is_done:
			sb.bg_color = Color("#27AE60", 0.15)
			sb.border_width_all = 1
			sb.border_color = Color("#27AE60", 0.3)
			btn.add_theme_color_override("font_color", Color("#27AE60"))
			btn.text = str(day) + "✓"
		elif is_future:
			sb.bg_color = Color("#ecf0f1", 0.5)
			btn.add_theme_color_override("font_color", Color("#bdc3c7"))
			btn.disabled = true
		else: # Past but not done
			sb.bg_color = Color("#ecf0f1")
			btn.add_theme_color_override("font_color", Color("#7f8c8d"))
		
		btn.add_theme_stylebox_override("normal", sb)
		btn.add_theme_stylebox_override("hover", sb)
		btn.add_theme_stylebox_override("pressed", sb)
		
		btn.pressed.connect(_select_day.bind(date_str))
		grid.add_child(btn)

func _select_day(date_str: String):
	selected_date_str = date_str
	var puzzle = _get_puzzle_for_date(date_str)
	selected_puzzle = puzzle
	
	# Update UI
	var parts = date_str.split("-")
	task_date_label.text = _get_month_name(int(parts[1])) + " " + parts[2] + ", " + parts[0]
	task_title.text = puzzle.title
	task_desc.text = puzzle.desc
	
	var is_done = date_str in GameManager.completed_daily_dates
	if is_done:
		solve_button.text = "PRACTICE AGAIN"
	else:
		solve_button.text = "START PUZZLE"
	
	# Highlight selected in grid (optional refinement)

func _get_puzzle_for_date(date_str: String):
	# Deterministic hash of the date string to pick a puzzle
	var hash_sum = 0
	for c in date_str:
		hash_sum += c.unicode_at(0)
	var idx = hash_sum % GameManager.puzzles.size()
	return GameManager.puzzles[idx]

func _get_month_name(m):
	return ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"][m]

func _on_solve_pressed():
	GameManager.is_daily_challenge = true
	GameManager.current_puzzle_id = selected_puzzle.id
	GameManager.current_daily_date = selected_date_str
	get_tree().change_scene_to_file("res://scenes/board.tscn")
