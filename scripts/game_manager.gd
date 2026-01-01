extends Node

# Piece types
enum Side { NONE, PLAYER, AI }
enum Mode { PV_AI, PV_P }

# Game state
var board = [] # 2D array [row][col]
var current_turn = Side.PLAYER
var current_mode = Mode.PV_AI # Default to PV_AI for now, will be set by menu
var selected_piece = null
var must_jump = false # For multi-jump logic
var win_streak = 0
var current_level = 1
var max_unlocked_level = 1
var move_history = [] # Stack of {pieces_state, turn, settings}
var is_daily_challenge = false
var daily_completed = false

# Settings
var forced_jumps = false
var movement_mode = "diagonal" # "diagonal" or "straight"

signal turn_changed(new_side)
signal game_over(winner)
signal piece_moved(from, to)
signal piece_captured(pos)

func _ready():
	load_game()
	setup_board()
	
	if not AchievementManager.is_unlocked("first_win"):
		# Just a check to ensure persistence works
		pass
	
	AchievementManager.achievement_unlocked.connect(func(id, title): save_game())

func save_game():
	var save_data = {
		"current_level": current_level,
		"max_unlocked_level": max_unlocked_level,
		"win_streak": win_streak,
		"stats": { 
			# Add other stats if needed
		},
		"achievements": AchievementManager.achievements
	}
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))

func load_game():
	if FileAccess.file_exists("user://savegame.json"):
		var file = FileAccess.open("user://savegame.json", FileAccess.READ)
		var json_str = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_str)
		if parse_result == OK:
			var data = json.get_data()
			current_level = data.get("current_level", 1)
			max_unlocked_level = data.get("max_unlocked_level", 1)
			win_streak = data.get("win_streak", 0)
			
			var saved_achievements = data.get("achievements", {})
			# Merge saved achievement state
			for id in saved_achievements:
				if AchievementManager.achievements.has(id):
					AchievementManager.achievements[id].unlocked = saved_achievements[id].unlocked

func setup_board():
	board = []
	for r in range(8):
		var row = []
		for c in range(8):
			row.append(null)
		board.append(row)

func get_daily_seed() -> int:
	var t = Time.get_date_dict_from_system()
	return t.year * 10000 + t.month * 100 + t.day

func reset_game():
	current_turn = Side.PLAYER
	selected_piece = null
	must_jump = false
	move_history = []
	is_daily_challenge = false
	setup_board()
	game_start_time = Time.get_unix_time_from_system()

func save_state():
	var state = []
	for r in range(8):
		var row = []
		for c in range(8):
			var p = get_piece_at(r, c)
			if p:
				row.append({"side": p.side, "is_king": p.is_king, "grid_pos": p.grid_pos})
			else:
				row.append(null)
		state.append(row)
	
	move_history.append({
		"board": state,
		"turn": current_turn,
		"must_jump": must_jump
	})
	
	if move_history.size() > 50:
		move_history.pop_front()

func undo():
	if move_history.size() <= 1: return
	
	# Current state is the last one, so pop it
	move_history.pop_back()
	var prev_state = move_history.back()
	
	current_turn = prev_state.turn
	must_jump = prev_state.must_jump
	
	# We need to tell the board to rebuild from state
	var board_node = get_tree().root.find_child("Board", true, false)
	if board_node:
		board_node.rebuild_from_state(prev_state.board)
	
	emit_signal("turn_changed", current_turn)

func check_win_condition(winner):
	# Achievement: First Win, Speed Demon
	if winner == Side.PLAYER:
		if current_level == max_unlocked_level and max_unlocked_level < 80:
			max_unlocked_level += 1
		
		AchievementManager.unlock("first_win")
		
		var duration = Time.get_unix_time_from_system() - game_start_time
		if duration < 60:
			AchievementManager.unlock("speed_demon")
			
		save_game()
		
		# ... existing streak logic ...
		if win_streak >= 3: AchievementManager.unlock("win_streak_3")
		if win_streak >= 5: AchievementManager.unlock("win_streak_5")
		if win_streak >= 10: AchievementManager.unlock("win_streak_10")
		
		if current_level >= 5: AchievementManager.unlock("level_5")
		if current_level >= 10: AchievementManager.unlock("level_10")
		if current_level >= 20: AchievementManager.unlock("level_20")
		if current_level >= 40: AchievementManager.unlock("level_40")
		if current_level >= 60: AchievementManager.unlock("level_60")
		if current_level >= 80: AchievementManager.unlock("level_80")

	elif winner == Side.AI:
		AchievementManager.unlock("first_loss")

# ... (skipped helper functions) ...

func evaluate_move(board_node, move):
	var score = 0
	if move.is_capture: score += 100
	if move.piece.is_king: score += 10
	
	# Center control
	var dist_to_center = abs(move.to.x - 3.5) + abs(move.to.y - 3.5)
	score -= dist_to_center * 2
	
	# Material Advancement: Encourage moving towards enemy side
	if move.piece.side == Side.AI:
		score += move.to.x * 2 # Higher X (row 7) is better for AI (starts at 0-2)
	
	# Mobility Score: Encourage using different pieces
	# (Simplified: Random nudge to break repetition)
	score += randf_range(0, 5)

	# Repetition Penalty: Avoid immediate back-and-forth
	# This would require tracking historical moves, which we can simplify:
	# Just discourage moving back to where we started if possible?
	# Hard to detect without history in this function.
	# The random mobility nudge should help enough for now.
	
	# King promotion incentive
	if move.to.x == 7: score += 50
	
	# Randomness for low levels
	if current_level <= 2:
		score += randf_range(-50, 50)
		
	return score

var game_start_time = 0 # Initialize this
	return r >= 0 and r < 8 and c >= 0 and c < 8

func get_piece_at(r, c):
	if is_on_board(r, c):
		return board[r][c]
	return null

func set_piece_at(r, c, piece):
	if is_on_board(r, c):
		board[r][c] = piece

func switch_turn():
	current_turn = Side.AI if current_turn == Side.PLAYER else Side.PLAYER
	emit_signal("turn_changed", current_turn)
	
	if current_mode == Mode.PV_AI and current_turn == Side.AI:
		# Trigger AI logic after a short delay for "thinking"
		await get_tree().create_timer(1.0).timeout
		play_ai_turn()

func play_ai_turn():
	var board_node = get_tree().root.find_child("Board", true, false)
	if not board_node:
		return

	var depth = 2
	if current_level > 5: depth = 3
	if current_level > 20: depth = 4
	if current_level > 40: depth = 5
	if current_level > 60: depth = 6
	
	var best_move = get_best_move(board_node, Side.AI, depth)
	
	if best_move.piece:
		board_node.execute_move(best_move.piece, best_move.to.x, best_move.to.y)
		
		# If multi-jump is active, keep playing
		if must_jump:
			await get_tree().create_timer(0.8).timeout
			play_ai_turn()
	else:
		emit_signal("game_over", Side.PLAYER)

func get_best_move(board_node, side, depth):
	var all_moves = []
	var pieces = []
	if must_jump and selected_piece:
		pieces = [selected_piece]
	else:
		for r in range(8):
			for c in range(8):
				var p = get_piece_at(r, c)
				if p and p.side == side:
					pieces.append(p)
	
	# Forced captures check
	var captures = board_node.get_all_captures(side)
	if captures.size() > 0:
		all_moves = captures
	else:
		for p in pieces:
			var moves = board_node.get_legal_moves(p)
			for m in moves:
				all_moves.append({"piece": p, "to": m.to, "is_capture": m.is_capture})
				
	if all_moves.size() == 0:
		return {"piece": null}
		
	# Simple heuristic evaluation for now (Minimax would be better but complex to state-copy Godot objects)
	# Let's use a weighted heuristic for higher levels
	var best_m = all_moves[0]
	var best_score = -100000
	
	for m in all_moves:
		var score = evaluate_move(board_node, m)
		if score > best_score:
			best_score = score
			best_m = m
			
	return best_m

func evaluate_move(_board_node, move):
	var score = 0
	if move.is_capture: score += 100
	if move.piece.is_king: score += 10
	
	# Center control
	var dist_to_center = abs(move.to.x - 3.5) + abs(move.to.y - 3.5)
	score -= dist_to_center * 2
	
	# King promotion incentive
	if move.to.x == 7: score += 50
	
	# Randomness for low levels
	if current_level <= 2:
		score += randf_range(-50, 50)
		
	return score
