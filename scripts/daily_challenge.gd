extends Control

@onready var calendar_grid = %CalendarGrid
@onready var month_label = %MonthLabel
@onready var streak_value = %StreakValue
@onready var play_btn = %PlayBtn

func _ready():
	_setup_calendar()
	_update_streak()
	play_btn.pressed.connect(_on_play_challenge)

func _setup_calendar():
	# Clear existing children
	for child in calendar_grid.get_children():
		child.queue_free()
	
	var now = Time.get_datetime_dict_from_system()
	month_label.text = _get_month_name(now.month) + " " + str(now.year)
	
	# Day headers
	var day_names = ["S", "M", "T", "W", "T", "F", "S"]
	for day in day_names:
		var label = Label.new()
		label.text = day
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color("#95a5a6")) # Muted Slate
		calendar_grid.add_child(label)
	
	# Get first day of month and total days
	var first_day = _get_first_day_of_month(now.year, now.month) # 0-6 (Sun-Sat)
	var total_days = _get_days_in_month(now.year, now.month)
	
	# Empty padding for first week
	for i in range(first_day):
		calendar_grid.add_child(Control.new())
	
	# Actual days
	for day in range(1, total_days + 1):
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(32, 32)
		
		var sb = StyleBoxFlat.new()
		sb.corner_radius_top_left = 6
		sb.corner_radius_top_right = 6
		sb.corner_radius_bottom_right = 6
		sb.corner_radius_bottom_left = 6
		
		# Current day highlight
		if day == now.day:
			sb.bg_color = Color(0.086, 0.627, 0.521, 0.2) # Stronger Emerald tint
			sb.border_width_left = 2
			sb.border_width_top = 2
			sb.border_width_right = 2
			sb.border_width_bottom = 2
			sb.border_color = Color("#16a085") # Emerald border
		else:
			sb.bg_color = Color.TRANSPARENT
		
		panel.add_theme_stylebox_override("panel", sb)
		
		var label = Label.new()
		label.text = str(day)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.add_theme_font_size_override("font_size", 13)
		label.add_theme_color_override("font_color", Color("#2c3e50") if day <= now.day else Color("#bdc3c7"))
		
		panel.add_child(label)
		calendar_grid.add_child(panel)

func _update_streak():
	var streak = GameManager.daily_streak
	streak_value.text = str(streak) + " DAYS"

func _on_play_challenge():
	# For now, start a random puzzle or the first one
	GameManager.is_daily_challenge = true
	# Logic to pick puzzle based on day could go here
	GameManager.get_tree().change_scene_to_file("res://scenes/board.tscn")

# Helper functions
func _get_month_name(m):
	return ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"][m - 1]

func _get_days_in_month(year, month):
	var days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if month == 2 and ((year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)):
		return 29
	return days[month - 1]

func _get_first_day_of_month(year, month):
	# Zeller's congruence simplified or use Time
	var t = Time.get_unix_time_from_datetime_dict({"year": year, "month": month, "day": 1, "hour": 0, "minute": 0, "second": 0})
	var dict = Time.get_datetime_dict_from_unix_time(t)
	return dict.weekday # 0 is Sunday in some systems, depends on Godot version.
	# In Godot 4, weekday is 0 (Sunday) to 6 (Saturday) if I recall correctly, checking...
	# Actually, in Godot 4: 0 = Sunday, 1 = Monday... 6 = Saturday.
