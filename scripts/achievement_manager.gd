extends Node

# Signal emitted when an achievement is unlocked
signal achievement_unlocked(achievement_id)

var save_path = "user://achievements.dat"

# Achievement Structure:
# { id: String, title: String, description: String, goal: int, category: String, unlocked: bool }
var achievements = {
	# PROGRESSION (20)
	"mastery_5": {"title": "Novice", "desc": "Reach Mastery Level 5", "goal": 5, "category": "progression"},
	"mastery_10": {"title": "Apprentice", "desc": "Reach Mastery Level 10", "goal": 10, "category": "progression"},
	"mastery_25": {"title": "Journeyman", "desc": "Reach Mastery Level 25", "goal": 25, "category": "progression"},
	"mastery_50": {"title": "Expert", "desc": "Reach Mastery Level 50", "goal": 50, "category": "progression"},
	"mastery_75": {"title": "Master", "desc": "Reach Mastery Level 75", "goal": 75, "category": "progression"},
	"mastery_100": {"title": "Grandmaster", "desc": "Reach Mastery Level 100", "goal": 100, "category": "progression"},
	"mastery_150": {"title": "Legend", "desc": "Reach Mastery Level 150", "goal": 150, "category": "progression"},
	"mastery_200": {"title": "Checkers God", "desc": "Clear all 200 Mastery Levels", "goal": 200, "category": "progression"},
	"first_win": {"title": "First Blood", "desc": "Win your first match", "goal": 1, "category": "progression"},
	"win_10": {"title": "Winner Culture", "desc": "Win 10 matches", "goal": 10, "category": "progression"},
	"win_50": {"title": "Pro Player", "desc": "Win 50 matches", "goal": 50, "category": "progression"},
	"win_100": {"title": "God of Board", "desc": "Win 100 matches", "goal": 100, "category": "progression"},
	"streak_3": {"title": "On Fire", "desc": "Reach a 3-win streak", "goal": 3, "category": "progression"},
	"streak_5": {"title": "Unstoppable", "desc": "Reach a 5-win streak", "goal": 5, "category": "progression"},
	"streak_10": {"title": "Invincible", "desc": "Reach a 10-win streak", "goal": 10, "category": "progression"},
	"daily_1": {"title": "Early Bird", "desc": "Complete your first Daily Challenge", "goal": 1, "category": "progression"},
	"daily_7": {"title": "Dedicated", "desc": "Complete 7 Daily Challenges", "goal": 7, "category": "progression"},
	"daily_30": {"title": "The Regular", "desc": "Complete 30 Daily Challenges", "goal": 30, "category": "progression"},
	"puzzles_5": {"title": "Puzzle Solver", "desc": "Solve 5 Puzzle scenarios", "goal": 5, "category": "progression"},
	"pvp_veteran": {"title": "World Traveler", "desc": "Play 20 Local PvP matches", "goal": 20, "category": "progression"},

	# COMBAT (20)
	"capture_1": {"title": "Tasted Victory", "desc": "Capture your first piece", "goal": 1, "category": "combat"},
	"capture_100": {"title": "The Collector", "desc": "Capture 100 pieces total", "goal": 100, "category": "combat"},
	"capture_500": {"title": "Warlord", "desc": "Capture 500 pieces total", "goal": 500, "category": "combat"},
	"capture_1000": {"title": "Soul Reaper", "desc": "Capture 1000 pieces total", "goal": 1000, "category": "combat"},
	"king_1": {"title": "Royal Blood", "desc": "Promote your first King", "goal": 1, "category": "combat"},
	"king_50": {"title": "King Maker", "desc": "Promote 50 Kings total", "goal": 50, "category": "combat"},
	"king_500": {"title": "Monarchy", "desc": "Promote 500 Kings total", "goal": 500, "category": "combat"},
	"multi_2": {"title": "Double Trouble", "desc": "Perform a double jump", "goal": 1, "category": "combat"},
	"multi_3": {"title": "Triple Threat", "desc": "Perform a triple jump", "goal": 1, "category": "combat"},
	"multi_4": {"title": "Combo King", "desc": "Perform a quadruple jump or higher", "goal": 1, "category": "combat"},
	"trap_king": {"title": "Crown Trap", "desc": "Capture an opponent's King", "goal": 1, "category": "combat"},
	"king_slayer": {"title": "Regicide", "desc": "Capture 50 Kings total", "goal": 50, "category": "combat"},
	"clean_sweep": {"title": "Total Domination", "desc": "Win without losing a single piece", "goal": 1, "category": "combat"},
	"comeback": {"title": "Against All Odds", "desc": "Win after being down 3 pieces", "goal": 1, "category": "combat"},
	"clutch": {"title": "Last Man Standing", "desc": "Win with only one piece left", "goal": 1, "category": "combat"},
	"fast_win": {"title": "Blitzkrieg", "desc": "Win in under 5 minutes", "goal": 1, "category": "combat"},
	"marathon": {"title": "Endurance Master", "desc": "A single game lasting over 15 minutes", "goal": 1, "category": "combat"},
	"greedy": {"title": "Hungry for More", "desc": "Capture 3 pieces in one turn", "goal": 1, "category": "combat"},
	"tactician": {"title": "Strategic Mind", "desc": "Win with more Kings than the opponent", "goal": 1, "category": "combat"},
	"merciless": {"title": "No Witnesses", "desc": "Capture all opponent pieces before they promote", "goal": 1, "category": "combat"},

	# SKILL & STYLE (20)
	"no_undo": {"title": "True Master", "desc": "Win 10 matches without using UNDO", "goal": 10, "category": "skill"},
	"level_50_no_undo": {"title": "No Safety Net", "desc": "Clear Mastery 50+ without Undo", "goal": 1, "category": "skill"},
	"forced_win": {"title": "Strict Ruler", "desc": "Win with 'Forced Jumps' ON", "goal": 1, "category": "skill"},
	"theme_classic": {"title": "Purist", "desc": "Play 10 matches on Classic Theme", "goal": 10, "category": "skill"},
	"theme_ocean": {"title": "Sea Salt", "desc": "Play 10 matches on Ocean Theme", "goal": 10, "category": "skill"},
	"theme_forest": {"title": "Woodsmen", "desc": "Play 10 matches on Forest Theme", "goal": 10, "category": "skill"},
	"theme_pink": {"title": "Fabulous", "desc": "Play 10 matches on Pink Theme", "goal": 10, "category": "skill"},
	"theme_night": {"title": "Night Owl", "desc": "Play 10 matches on Night Theme", "goal": 10, "category": "skill"},
	"all_themes": {"title": "Decorator", "desc": "Play a match on every theme", "goal": 5, "category": "style"},
	"explorer": {"title": "The Explorer", "desc": "Visit every menu page", "goal": 1, "category": "skill"},
	"back_defense": {"title": "Shield Wall", "desc": "Win without moving your back row pieces", "goal": 1, "category": "skill"},
	"king_rush": {"title": "Early Ascension", "desc": "Promote a King in less than 5 moves", "goal": 1, "category": "skill"},
	"patient": {"title": "The Patient", "desc": "Spend 10 minutes total thinking about moves", "goal": 600, "category": "skill"},
	"quick_reflex": {"title": "Speedrunner", "desc": "Average move time < 1 second in a match", "goal": 1, "category": "skill"},
	"high_level": {"title": "Giant Slayer", "desc": "Beat AI level 150+", "goal": 1, "category": "skill"},
	"max_level": {"title": "Impossible Task", "desc": "Beat AI level 200", "goal": 1, "category": "skill"},
	"undo_fan": {"title": "Time Traveler", "desc": "Use UNDO 100 times total", "goal": 100, "category": "skill"},
	"restarting": {"title": "Try Again", "desc": "Restart a match 10 times", "goal": 10, "category": "skill"},
	"patience_is_virtue": {"title": "Deep Thinker", "desc": "Wait 30 seconds before making a move", "goal": 1, "category": "skill"},
	"lucky_break": {"title": "Fortuna", "desc": "Win a match where the AI had a better score", "goal": 1, "category": "skill"}
}

# Stats to track
var stats = {
	"mastery_level": 0,
	"total_wins": 0,
	"win_streak": 0,
	"daily_count": 0,
	"puzzles_solved": 0,
	"pvp_matches": 0,
	"total_captures": 0,
	"total_kings": 0,
	"king_captures": 0,
	"undo_count": 0,
	"classic_played": 0,
	"ocean_played": 0,
	"forest_played": 0,
	"pink_played": 0,
	"night_played": 0,
	"themes_used": [],
	"visited_menus": [],
	"restart_count": 0,
	"total_think_time": 0.0,
	"wins_no_undo": 0
}

var unlocked_achievements = []

func _ready():
	load_achievements()

func save_achievements():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		var data = {
			"stats": stats,
			"unlocked": unlocked_achievements
		}
		file.store_string(JSON.stringify(data))

func load_achievements():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		var data = test_json_conv.get_data()
		if data:
			stats = data.get("stats", stats)
			unlocked_achievements = data.get("unlocked", [])

func update_stat(stat_name: String, value: float, relative: bool = true):
	if stat_name in stats:
		if relative:
			stats[stat_name] += value
		else:
			stats[stat_name] = value
		
		_check_achievements()
		save_achievements()

func add_visited_menu(menu_name: String):
	if not menu_name in stats.visited_menus:
		stats.visited_menus.append(menu_name)
		_check_achievements()
		save_achievements()

func add_theme_used(index: int):
	if not index in stats.themes_used:
		stats.themes_used.append(index)
		_check_achievements()
		save_achievements()

func _check_achievements():
	# PROGRESSION
	_check("mastery_5", stats.mastery_level >= 5)
	_check("mastery_10", stats.mastery_level >= 10)
	_check("mastery_25", stats.mastery_level >= 25)
	_check("mastery_50", stats.mastery_level >= 50)
	_check("mastery_75", stats.mastery_level >= 75)
	_check("mastery_100", stats.mastery_level >= 100)
	_check("mastery_150", stats.mastery_level >= 150)
	_check("mastery_200", stats.mastery_level >= 200)
	_check("first_win", stats.total_wins >= 1)
	_check("win_10", stats.total_wins >= 10)
	_check("win_50", stats.total_wins >= 50)
	_check("win_100", stats.total_wins >= 100)
	_check("streak_3", stats.win_streak >= 3)
	_check("streak_5", stats.win_streak >= 5)
	_check("streak_10", stats.win_streak >= 10)
	_check("daily_1", stats.daily_count >= 1)
	_check("daily_7", stats.daily_count >= 7)
	_check("daily_30", stats.daily_count >= 30)
	_check("puzzles_5", stats.puzzles_solved >= 5)
	_check("pvp_veteran", stats.pvp_matches >= 20)

	# COMBAT
	_check("capture_1", stats.total_captures >= 1)
	_check("capture_100", stats.total_captures >= 100)
	_check("capture_500", stats.total_captures >= 500)
	_check("capture_1000", stats.total_captures >= 1000)
	_check("king_1", stats.total_kings >= 1)
	_check("king_50", stats.total_kings >= 50)
	_check("king_500", stats.total_kings >= 500)
	_check("king_slayer", stats.king_captures >= 50)
	
	# SKILL
	_check("no_undo", stats.wins_no_undo >= 10)
	_check("theme_classic", stats.classic_played >= 10)
	_check("theme_ocean", stats.ocean_played >= 10)
	_check("theme_forest", stats.forest_played >= 10)
	_check("theme_pink", stats.pink_played >= 10)
	_check("theme_night", stats.night_played >= 10)
	_check("all_themes", stats.themes_used.size() >= 5)
	_check("explorer", stats.visited_menus.size() >= 5) # daily, pvp, mastery, achievements, settings
	_check("undo_fan", stats.undo_count >= 100)
	_check("restarting", stats.restart_count >= 10)
	_check("patient", stats.total_think_time >= 600)

func _check(id: String, condition: bool):
	if condition and not id in unlocked_achievements:
		unlock_achievement(id)

func unlock_achievement(id: String):
	if not id in unlocked_achievements:
		unlocked_achievements.append(id)
		emit_signal("achievement_unlocked", id)
		save_achievements()
		show_toast(achievements[id].title)
		print("ACHIEVEMENT UNLOCKED: ", achievements[id].title)

func show_toast(title: String):
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	var tree = get_tree()
	if tree and tree.root:
		tree.root.add_child(canvas)
	else:
		return
	
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(400, 80)
	panel.anchors_preset = Control.PRESET_CENTER_TOP
	panel.position.y = -100 # Start offscreen
	canvas.add_child(panel)
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color.WHITE
	sb.set_corner_radius_all(32)
	sb.shadow_color = Color(0, 0, 0, 0.05)
	sb.shadow_size = 20
	panel.add_theme_stylebox_override("panel", sb)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(vbox)
	
	var label1 = Label.new()
	label1.text = "Award Unlocked"
	label1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label1.add_theme_font_size_override("font_size", 12)
	label1.add_theme_color_override("font_color", Color("#1B4332", 0.6))
	vbox.add_child(label1)
	
	var label2 = Label.new()
	label2.text = title
	label2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label2.add_theme_font_size_override("font_size", 24)
	label2.add_theme_color_override("font_color", Color("#1B4332"))
	vbox.add_child(label2)
	
	# Animate in and out
	var tween = canvas.create_tween()
	tween.tween_property(panel, "position:y", 32, 0.6).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.tween_interval(3.0)
	tween.tween_property(panel, "position:y", -100, 0.6).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	tween.tween_callback(canvas.queue_free)

# Helper for one-off achievements (not based on cumulative stats)
func trigger_manual_achievement(id: String):
	if id in achievements:
		unlock_achievement(id)
