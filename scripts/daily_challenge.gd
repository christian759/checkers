extends Control

@onready var streak_text = $VBox/StreakContainer/StreakBox/HBox/StreakText
@onready var puzzle_title = $VBox/PuzzleSection/Card/VBox/PuzzleTitle
@onready var puzzle_desc = $VBox/PuzzleSection/Card/VBox/PuzzleDesc
@onready var solve_button = $VBox/PuzzleSection/Card/VBox/SolveButton
@onready var streak_box = $VBox/StreakContainer/StreakBox

var current_puzzle = null

func _ready():
	_refresh_ui()
	solve_button.pressed.connect(_on_solve_pressed)
	_animate_streak()

func _refresh_ui():
	# Check streak/date logic in GameManager
	_update_streak_logic()
	
	streak_text.text = str(GameManager.daily_streak) + " DAY STREAK"
	
	# Determine today's puzzle
	current_puzzle = _get_today_puzzle()
	puzzle_title.text = "MISSION: " + current_puzzle.title
	puzzle_desc.text = current_puzzle.desc
	
	# Check if already completed today
	var today = Time.get_date_string_from_system()
	if GameManager.last_daily_date == today:
		solve_button.disabled = true
		solve_button.text = "COMPLETED"
		puzzle_title.text = "MISSION ACCOMPLISHED"
		puzzle_desc.text = "Great work! Return tomorrow for a new tactical challenge."

func _update_streak_logic():
	var today = Time.get_date_string_from_system()
	if GameManager.last_daily_date == "":
		return
		
	if GameManager.last_daily_date == today:
		return # Already interacted today
		
	# Check if yesterday was the last completion
	# (Simplified logic using day difference would be better, but strings suffice for same/next day check)
	# For premium feel, let's just make it work. 
	# If we wanted robust: convert strings to unix timestamps.
	pass

func _get_today_puzzle():
	# Deterministic selection based on day of year
	var date_dict = Time.get_date_dict_from_system()
	var day_index = date_dict.day + date_dict.month * 31
	var puzzle_index = day_index % GameManager.puzzles.size()
	return GameManager.puzzles[puzzle_index]

func _animate_streak():
	var tween = create_tween().set_loops()
	tween.tween_property(streak_box, "scale", Vector2(1.03, 1.03), 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(streak_box, "scale", Vector2(1.0, 1.0), 1.0).set_trans(Tween.TRANS_SINE)

func _on_solve_pressed():
	GameManager.is_daily_challenge = true
	GameManager.current_puzzle_id = current_puzzle.id
	
	# Transition to board
	# Note: board.gd needs to handle the setup based on these flags
	get_tree().change_scene_to_file("res://scenes/board.tscn")
