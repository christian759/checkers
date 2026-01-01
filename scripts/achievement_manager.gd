extends Node

var achievements = {
	"first_win": { "title": "First Steps", "desc": "Win your first game", "unlocked": false },
	"level_5": { "title": "Getting Serious", "desc": "Reach Level 5", "unlocked": false },
	"level_10": { "title": "Double Digits", "desc": "Reach Level 10", "unlocked": false },
	"level_20": { "title": "Pro Player", "desc": "Reach Level 20", "unlocked": false },
	"level_40": { "title": "Veteran", "desc": "Reach Level 40", "unlocked": false },
	"level_60": { "title": "Master", "desc": "Reach Level 60", "unlocked": false },
	"level_80": { "title": "Grandmaster", "desc": "Complete all 80 levels", "unlocked": false },
	"win_streak_3": { "title": "On Fire", "desc": "Win 3 games in a row", "unlocked": false },
	"win_streak_5": { "title": "Unstoppable", "desc": "Win 5 games in a row", "unlocked": false },
	"win_streak_10": { "title": "Legendary", "desc": "Win 10 games in a row", "unlocked": false },
	"king_maker": { "title": "Royalty", "desc": "Promote a piece to King", "unlocked": false },
	"double_jump": { "title": "Hop Scotch", "desc": "Perform a double jump", "unlocked": false },
	"triple_jump": { "title": "Triple Threat", "desc": "Perform a triple jump", "unlocked": false },
	"quad_jump": { "title": "Quad God", "desc": "Perform a quad jump", "unlocked": false },
	"first_loss": { "title": "Learning Experience", "desc": "Lose a game", "unlocked": false },
	"flawless": { "title": "Flawless Victory", "desc": "Win without losing any pieces", "unlocked": false },
	"comeback": { "title": "Comeback Kid", "desc": "Win with only 1 piece left", "unlocked": false },
	"pacifist": { "title": "Peaceful", "desc": "Win by blocking opponents moves", "unlocked": false },
	"speed_demon": { "title": "Speed Demon", "desc": "Win in under 30 seconds", "unlocked": false },
	"slow_poke": { "title": "Thoughtful", "desc": "Take 2 minutes on a single move", "unlocked": false },
	"undoer": { "title": "Time Traveler", "desc": "Use the Undo button", "unlocked": false },
	"first_capture": { "title": "First Blood", "desc": "Capture an enemy piece", "unlocked": false },
	"capture_100": { "title": "Hunter", "desc": "Capture 100 pieces total", "unlocked": false },
	"capture_500": { "title": "Predator", "desc": "Capture 500 pieces total", "unlocked": false },
	"capture_1000": { "title": "Apex Predator", "desc": "Capture 1000 pieces total", "unlocked": false },
	"king_100": { "title": "Monarch", "desc": "Create 100 Kings total", "unlocked": false },
	"daily_hero": { "title": "Daily Ritual", "desc": "Complete a Daily Challenge", "unlocked": false },
	"daily_streak_3": { "title": "Dedicated", "desc": "Complete 3 Daily Challenges in a row", "unlocked": false },
	"daily_streak_7": { "title": "Committed", "desc": "Complete 7 Daily Challenges in a row", "unlocked": false },
	"pvp_match": { "title": "Social Butterfly", "desc": "Play a PvP match", "unlocked": false },
	"rule_bender": { "title": "Variant", "desc": "Play with Straight Checkers rules", "unlocked": false },
	"freedom": { "title": "Free Spirit", "desc": "Disable Forced Jumps", "unlocked": false },
	"clicker": { "title": "Indecisive", "desc": "Select and deselect pieces 50 times in a game", "unlocked": false },
	"survivor": { "title": "Survivor", "desc": "Win with 1 King against 3 enemies", "unlocked": false },
	"greedy": { "title": "Greedy", "desc": "Capture 3 kings in one game", "unlocked": false },
	"sacrificial": { "title": "Gambit", "desc": "Win after sacrificing 5 pieces", "unlocked": false },
	"blitz": { "title": "Blitz", "desc": "Win in under 20 moves", "unlocked": false },
	"marathon": { "title": "Marathon", "desc": "Win a game lasting over 100 moves", "unlocked": false },
	"no_kings": { "title": "Peasant Revolt", "desc": "Win without promoting any Kings", "unlocked": false },
	"full_house": { "title": "Full House", "desc": "Win with 10 or more pieces left", "unlocked": false },
	"lucky": { "title": "Lucky Break", "desc": "Win a game where opponent had a forced win", "unlocked": false }, # Hard to detect, maybe just random chance?
	"architect": { "title": "Architect", "desc": "Create a wall of 4 pieces", "unlocked": false },
	"explorer": { "title": "Explorer", "desc": "Unlock Level 25", "unlocked": false },
	"conqueror": { "title": "Conqueror", "desc": "Unlock Level 50", "unlocked": false },
	"champion": { "title": "Champion", "desc": "Unlock Level 75", "unlocked": false },
	"hoarder": { "title": "Rich", "desc": "Collect 5000 Coins", "unlocked": false },
	"big_spender": { "title": "Consumer", "desc": "Visit the Shop", "unlocked": false },
	"perfectionist": { "title": "Perfectionist", "desc": "3 Flawless victories", "unlocked": false },
	"student": { "title": "Student", "desc": "Lost 5 games in a row", "unlocked": false },
	"teacher": { "title": "Teacher", "desc": "Beat the AI at Max Level", "unlocked": false },
	"checkmate": { "title": "Checkmate", "desc": "Capture the last enemy piece with a King", "unlocked": false }
}

signal achievement_unlocked(id, title)

func unlock(id):
	if achievements.has(id):
		if not achievements[id].unlocked:
			achievements[id].unlocked = true
			emit_signal("achievement_unlocked", id, achievements[id].title)
			# GameManager should listen to this signal and save
			
			# Show notification
			var popup = load("res://scenes/confetti.tscn").instantiate()
			# Ideally we'd have a specific toast notification scene, but for now we'll just save it
			print("Unlocked: " + achievements[id].title)

func is_unlocked(id):
	if achievements.has(id):
		return achievements[id].unlocked
	return false
