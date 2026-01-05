extends Node

# Piece types
enum Side {NONE, PLAYER, AI}
enum Mode {PV_AI, PV_P}

# Game state
var board = [] # 2D array [row][col]
var current_turn = Side.PLAYER
var current_mode = Mode.PV_AI # Default to PV_AI for now, will be set by menu
var current_level = 1
var selected_piece = null
var must_jump = false # For multi-jump logic
var win_streak = 0
var max_unlocked_level = 1
var move_history = [] # Stack of {pieces_state, turn, settings}
var is_daily_challenge = false
var daily_completed = false
var game_start_time = 0

# Match Settings (Lobby)
var match_mode = Mode.PV_AI
var match_ai_level = 1
var match_theme_index = 0
var match_start_side = Side.PLAYER

# Mastery Progression Tracking
var completed_levels = [] # Array of level IDs (integers)

# Daily Challenge & Persistence
var daily_streak = 0
var last_daily_date = "" # Format: "2026-01-05"
var current_puzzle_id = -1
var save_path = "user://save_game.dat"

var puzzles = [
	{
		"id": 0,
		"title": "THE FORK",
		"desc": "Capture the AI king using a strategic fork.",
		"setup": [
			{"r": 5, "c": 3, "side": Side.PLAYER, "king": false},
			{"r": 5, "c": 5, "side": Side.PLAYER, "king": false},
			{"r": 3, "c": 3, "side": Side.AI, "king": true}
		]
	},
	{
		"id": 1,
		"title": "CORNER TRAP",
		"desc": "Box in the opponent's piece against the edge.",
		"setup": [
			{"r": 1, "c": 1, "side": Side.PLAYER, "king": true},
			{"r": 0, "c": 0, "side": Side.AI, "king": false}
		]
	}
]

# Settings
var forced_jumps = false
var movement_mode = "diagonal" # "diagonal" or "straight"

signal turn_changed(new_side)
signal game_over(winner) # Simplified signature for consistency


const BOARD_THEMES = [
	{"name": "CLASSIC", "light": Color("#f9f9f9"), "dark": Color("#2ecc71")},
	{"name": "OCEAN", "light": Color("#e0f7fa"), "dark": Color("#0277bd")},
	{"name": "FOREST", "light": Color("#dcedc8"), "dark": Color("#33691e")},
	{"name": "PINK", "light": Color("#f8bbd0"), "dark": Color("#c2185b")},
	{"name": "NIGHT", "light": Color("#cfcfcf"), "dark": Color("#202020")}
]


var board_theme_index = 0

func _ready():
	load_data()
	setup_board()

func save_data():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		var data = {
			"daily_streak": daily_streak,
			"last_daily_date": last_daily_date,
			"max_unlocked_level": max_unlocked_level,
			"win_streak": win_streak,
			"completed_levels": completed_levels
		}
		file.store_string(JSON.stringify(data))

func load_data():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		var data = test_json_conv.get_data()
		if data:
			daily_streak = data.get("daily_streak", 0)
			last_daily_date = data.get("last_daily_date", "")
			max_unlocked_level = data.get("max_unlocked_level", 1)
			win_streak = data.get("win_streak", 0)
			completed_levels = data.get("completed_levels", [])

func setup_board():
	board = []
	for r in range(8):
		var row = []
		for c in range(8):
			row.append(null)
		board.append(row)

func complete_daily():
	var today = Time.get_date_string_from_system()
	if last_daily_date != today:
		daily_streak += 1
		last_daily_date = today
		save_data()

func start_custom_game(mode, ai_level, theme_index, start_side):
	match_mode = mode
	match_ai_level = ai_level
	match_theme_index = theme_index
	match_start_side = start_side
	
	current_mode = mode
	current_level = ai_level
	board_theme_index = theme_index
	current_turn = start_side
	is_daily_challenge = false
	
	setup_board()
	get_tree().change_scene_to_file("res://scenes/board.tscn")

func start_mastery_level(level):
	match_mode = Mode.PV_AI
	match_ai_level = level
	match_theme_index = 0 # Classic for Mastery
	match_start_side = Side.PLAYER
	
	current_mode = Mode.PV_AI
	current_level = level
	board_theme_index = 0
	current_turn = Side.PLAYER
	is_daily_challenge = false
	
	setup_board()
	get_tree().change_scene_to_file("res://scenes/board.tscn")

func reset_game():
	current_turn = Side.PLAYER
	selected_piece = null
	must_jump = false
	setup_board()


func check_win_condition(winner):
	print("[DEBUG] Win condition triggered for: ", "PLAYER" if winner == Side.PLAYER else "AI")
	if winner == Side.PLAYER:
		if not current_level in completed_levels:
			completed_levels.append(current_level)
		
		if current_level == max_unlocked_level:
			max_unlocked_level = min(max_unlocked_level + 1, 200)
			
		win_streak += 1
	else:
		win_streak = 0
		
	save_data()
	emit_signal("game_over", winner)

func restart_match():
	setup_board()
	# Reset state as needed
	current_turn = Side.PLAYER # Usually player starts
	must_jump = false
	selected_piece = null

func is_on_board(r, c):
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
	
	# Check if the player who just inherited the turn has any moves
	var board_node = get_tree().root.find_child("Board", true, false)
	if board_node and not board_node.has_valid_moves(current_turn):
		check_win_condition(Side.AI if current_turn == Side.PLAYER else Side.PLAYER)
		return

	if current_mode == Mode.PV_AI and current_turn == Side.AI:
		# Trigger AI logic after a short delay for "thinking"
		await get_tree().create_timer(1.0).timeout
		play_ai_turn()

func play_ai_turn():
	var board_node = get_tree().root.find_child("Board", true, false)
	if not board_node: return

	# Advanced depth mapping for 1-200 range
	var depth = 2
	if match_ai_level > 10: depth = 3
	if match_ai_level > 30: depth = 4
	if match_ai_level > 70: depth = 5
	if match_ai_level > 120: depth = 6
	if match_ai_level > 170: depth = 8 # Grandmaster
	
	# Initial state
	var current_state = _get_board_state()
	
	# Start Minimax
	var result = _minimax(current_state, depth, -INF, INF, true, must_jump, selected_piece)
	var best_move = result.move
	
	if best_move and best_move.piece_node:
		board_node.execute_move(best_move.piece_node, best_move.to.x, best_move.to.y)
		
		if must_jump:
			await get_tree().create_timer(0.6).timeout
			play_ai_turn()
	else:
		# AI has no moves
		check_win_condition(Side.PLAYER)

func _get_board_state():
	var state = []
	for r in range(8):
		var row = []
		for c in range(8):
			var p = board[r][c]
			if p:
				row.append({"side": p.side, "is_king": p.is_king, "node": p})
			else:
				row.append(null)
		state.append(row)
	return state

func _minimax(state, depth, alpha, beta, is_max, m_jump, m_piece):
	if depth == 0:
		return {"score": _evaluate_board(state), "move": null}
	
	var moves = _get_all_sim_moves(state, Side.AI if is_max else Side.PLAYER, m_jump, m_piece)
	
	if moves.size() == 0:
		if m_jump:
			# If we were in a multi-jump but have no more jumps, it's just a turn switch
			return _minimax(state, depth, alpha, beta, not is_max, false, null)
		
		# True end of game for this branch
		return {"score": - 10000 if is_max else 10000, "move": null}
	
	var best_move = moves.pick_random()
	
	if is_max:
		var max_eval = - INF
		for move in moves:
			var next_state = _simulate_move(state, move)
			# Handle multi-jump in simulation
			var m_j = false
			var m_p = null
			if move.is_capture:
				var m_moves = _get_sim_legal_moves(next_state, move.to.x, move.to.y)
				for m in m_moves:
					if m.is_capture:
						m_j = true
						m_p = next_state[move.to.x][move.to.y]
						break
			
			var eval = _minimax(next_state, depth - 1, alpha, beta, m_j, m_j, m_p).score
			if eval > max_eval:
				max_eval = eval
				best_move = move
			alpha = max(alpha, eval)
			if beta <= alpha: break
		return {"score": max_eval, "move": best_move}
	else:
		var min_eval = INF
		for move in moves:
			var next_state = _simulate_move(state, move)
			var m_j = false
			var m_p = null
			if move.is_capture:
				var m_moves = _get_sim_legal_moves(next_state, move.to.x, move.to.y)
				for m in m_moves:
					if m.is_capture:
						m_j = true
						m_p = next_state[move.to.x][move.to.y]
						break
						
			var eval = _minimax(next_state, depth - 1, alpha, beta, not m_j, m_j, m_p).score
			if eval < min_eval:
				min_eval = eval
				best_move = move
			beta = min(beta, eval)
			if beta <= alpha: break
		return {"score": min_eval, "move": best_move}

func _evaluate_board(state):
	var score = 0
	for r in range(8):
		for c in range(8):
			var p = state[r][c]
			if not p: continue
			
			var multiplier = 1 if p.side == Side.AI else -1
			var val = 10 if not p.is_king else 30
			
			# Positional bonus (center control)
			var center_dist = abs(r - 3.5) + abs(c - 3.5)
			val += (4 - center_dist) * 2
			
			# Protection (Back row)
			if p.side == Side.AI and r == 0: val += 5
			if p.side == Side.PLAYER and r == 7: val += 5
			
			score += val * multiplier
	
	# Material Advantage
	return score

func _get_all_sim_moves(state, side, m_jump, m_piece):
	var all_moves = []
	var captures = []
	
	if m_jump and m_piece:
		# Find the coordinates of m_piece in the virtual state by comparing node references
		var target_node = m_piece if typeof(m_piece) != TYPE_DICTIONARY else m_piece.get("node")
		for r in range(8):
			for c in range(8):
				var p = state[r][c]
				if p and p.get("node") == target_node:
					var m = _get_sim_legal_moves(state, r, c)
					for move in m:
						if move.is_capture:
							captures.append(move)
	else:
		for r in range(8):
			for c in range(8):
				var p = state[r][c]
				if p and p.side == side:
					var m = _get_sim_legal_moves(state, r, c)
					for move in m:
						if move.is_capture:
							captures.append(move)
						else:
							all_moves.append(move)
	
	# Forced capture rule
	if captures.size() > 0:
		return captures
	return all_moves

func _get_sim_legal_moves(state, r, c):
	var p = state[r][c]
	if not p: return []
	
	var moves = []
	var directions = [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]
	
	for d in directions:
		# Simplified: Check captures (2 steps)
		var mid_r = r + d.x
		var mid_c = c + d.y
		var end_r = r + d.x * 2
		var end_c = c + d.y * 2
		
		# Move forward check for non-kings
		if not p.is_king:
			if p.side == Side.AI and d.x < 0: continue
			if p.side == Side.PLAYER and d.x > 0: continue
			
		if is_on_board(end_r, end_c):
			var mid_p = state[mid_r][mid_c]
			if mid_p and mid_p.side != p.side and state[end_r][end_c] == null:
				moves.append({"from": Vector2i(r, c), "to": Vector2i(end_r, end_c), "is_capture": true, "piece_node": p.node})
				
		# Normal moves (1 step)
		var dest_r = r + d.x
		var dest_c = c + d.y
		if is_on_board(dest_r, dest_c) and state[dest_r][dest_c] == null:
			moves.append({"from": Vector2i(r, c), "to": Vector2i(dest_r, dest_c), "is_capture": false, "piece_node": p.node})
			
	return moves

func _simulate_move(state, move):
	var new_state = []
	for r in range(8):
		new_state.append(state[r].duplicate())
	
	var p = new_state[move.from.x][move.from.y]
	new_state[move.from.x][move.from.y] = null
	new_state[move.to.x][move.to.y] = p
	
	if move.is_capture:
		var mid_r = (move.from.x + move.to.x) / 2
		var mid_c = (move.from.y + move.to.y) / 2
		new_state[mid_r][mid_c] = null
		
	# King promotion
	if not p.is_king:
		if (p.side == Side.AI and move.to.x == 7) or (p.side == Side.PLAYER and move.to.x == 0):
			var np = p.duplicate()
			np.is_king = true
			new_state[move.to.x][move.to.y] = np
			
	return new_state
