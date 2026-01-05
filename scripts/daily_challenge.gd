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
	
	# Initial solve button style
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color("#1B4332")
	sb.set_corner_radius_all(32)
	solve_button.add_theme_stylebox_override("normal", sb)
	solve_button.add_theme_stylebox_override("hover", sb)

func _refresh_calendar():
	for child in grid.get_children():
		child.queue_free()
	
	var today_dict = Time.get_date_dict_from_system()
	month_label.text = _get_month_name(today_dict.month) + " " + str(today_dict.year)
	streak_label.text = str(GameManager.daily_streak) + " Day Streak"
	
	var days_in_month = 31
	if today_dict.month == 2: days_in_month = 28
	elif today_dict.month in [4, 6, 9, 11]: days_in_month = 30
	
	for day in range(1, days_in_month + 1):
		var date_str = "%04d-%02d-%02d" % [today_dict.year, today_dict.month, day]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(48, 48)
		btn.text = str(day)
		btn.add_theme_font_size_override("font_size", 16)
		
		var sb = StyleBoxFlat.new()
		sb.set_corner_radius_all(24)
		sb.anti_aliasing = true
		
		var is_today = day == today_dict.day
		var is_future = day > today_dict.day
		
		if is_today:
			sb.bg_color = Color("#1B4332")
			btn.add_theme_color_override("font_color", Color.WHITE)
		elif is_future:
			sb.bg_color = Color("#1B4332", 0.05)
			btn.add_theme_color_override("font_color", Color("#1B4332", 0.2))
			btn.disabled = true
		else:
			var is_done = GameManager.completed_daily_dates.has(date_str)
			if is_done:
				sb.bg_color = Color("#1B4332", 0.15)
				btn.add_theme_color_override("font_color", Color("#1B4332"))
				btn.text = "•"
			else:
				sb.bg_color = Color.WHITE
				sb.set_border_width_all(1)
				sb.border_color = Color("#1B4332", 0.1)
				btn.add_theme_color_override("font_color", Color("#1B4332", 0.6))
		
		btn.add_theme_stylebox_override("normal", sb)
		btn.add_theme_stylebox_override("hover", sb)
		btn.pressed.connect(_select_day.bind(date_str))
		grid.add_child(btn)

func _select_day(date_str: String):
	selected_date_str = date_str
	var puzzle = _get_puzzle_for_date(date_str)
	selected_puzzle = puzzle
	
	var parts = date_str.split("-")
	task_date_label.text = _get_month_name(int(parts[1])) + " " + parts[2]
	
	var d = Time.get_date_dict_from_system()
	var today_str = "%04d-%02d-%02d" % [d.year, d.month, d.day]
	
	if date_str > today_str:
		task_title.text = "Locked"
		task_desc.text = "This challenge will be available on the scheduled date."
		solve_button.disabled = true
		solve_button.text = "Not Available"
	else:
		var is_done = GameManager.completed_daily_dates.has(date_str)
		task_title.text = "Capture Challenge"
		task_desc.text = "Solve the puzzle to maintain your daily streak and sharpen your skills."
		solve_button.disabled = false
		solve_button.text = "Replay Challenge" if is_done else "Start Challenge"

func _get_puzzle_for_date(date_str: String):
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
