extends Node

# Piece types
enum Side {NONE, PLAYER, AI}
enum Mode {PV_AI, PV_P}

# Game state
var board = [] # 2D array [row][col]
var current_turn = Side.PLAYER
var current_mode = Mode.PV_AI
var current_level = 1
var selected_piece = null
var must_jump = false # For multi-jump logic
var win_streak = 0
var max_unlocked_level = 1
var move_history = [] # Stack of {pieces_state, turn, settings}
var is_daily_challenge = false
var is_mastery = false
var daily_completed = false
var game_start_time = 0
var is_calculating = false # Lock input while AI thinks
var undo_used_in_match = false
var active_theme_played = false

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
var completed_dailies = [] # Array of date strings "YYYY-MM-DD"
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
signal game_over(winner)
signal board_restored()


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
			"completed_levels": completed_levels,
			"completed_dailies": completed_dailies
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
			completed_dailies = data.get("completed_dailies", [])

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
		if not today in completed_dailies:
			completed_dailies.append(today)
		AchievementManager.update_stat("daily_count", 1)
		save_data()

func start_custom_game(mode, ai_level, theme_index, start_side):
	undo_used_in_match = false
	active_theme_played = false
	game_start_time = Time.get_ticks_msec()
	AchievementManager.add_theme_used(theme_index)
	
	match_mode = mode
	match_ai_level = ai_level
	match_theme_index = theme_index
	match_start_side = start_side
	
	current_mode = mode
	current_level = ai_level
	board_theme_index = theme_index
	current_turn = start_side
	is_daily_challenge = false
	is_mastery = false
	
	setup_board()
	get_tree().change_scene_to_file("res://scenes/board.tscn")

func start_mastery_level(level):
	undo_used_in_match = false
	active_theme_played = false
	game_start_time = Time.get_ticks_msec()
	AchievementManager.add_theme_used(0)
	match_mode = Mode.PV_AI
	match_ai_level = level
	match_theme_index = 0
	match_start_side = Side.PLAYER
	
	current_mode = Mode.PV_AI
	current_level = level
	board_theme_index = 0
	current_turn = Side.PLAYER
	is_daily_challenge = false
	is_mastery = true
	
	setup_board()
	get_tree().change_scene_to_file("res://scenes/board.tscn")

func reset_game():
	current_turn = Side.PLAYER
	selected_piece = null
	must_jump = false
	is_calculating = false
	move_history = []
	setup_board()

func push_history():
	var snapshot = {
		"board": [],
		"turn": current_turn,
		"must_jump": must_jump,
		"selected_piece_pos": selected_piece.grid_pos if selected_piece else null,
		"level": current_level
	}
	
	for r in range(8):
		var row = []
		for c in range(8):
			var p = board[r][c]
			if p:
				var side_val = p.side if p is Piece else p.get("side")
				var king_val = p.is_king if p is Piece else p.get("is_king")
				var pos_val = p.grid_pos if p is Piece else p.get("grid_pos")
				row.append({"side": side_val, "is_king": king_val, "grid_pos": pos_val})
			else:
				row.append(null)
		snapshot.board.append(row)
	
	move_history.append(snapshot)
	if move_history.size() > 50:
		move_history.remove_at(0)

func undo_move():
	if move_history.size() == 0 or is_calculating:
		return
	
	undo_used_in_match = true
	AchievementManager.update_stat("undo_count", 1)
	var steps = 2 if current_mode == Mode.PV_AI else 1
	if must_jump: steps = 1
	
	for i in range(steps):
		if move_history.size() > 0:
			var snapshot = move_history.pop_back()
			_restore_snapshot(snapshot)
	
	emit_signal("board_restored")

func _restore_snapshot(snapshot):
	current_turn = snapshot.turn
	must_jump = snapshot.must_jump
	current_level = snapshot.level
	
	for r in range(8):
		for c in range(8):
			board[r][c] = snapshot.board[r][c]

func check_win_condition(winner):
	if winner == Side.PLAYER:
		if not current_level in completed_levels:
			completed_levels.append(current_level)
		
		if current_level == max_unlocked_level:
			max_unlocked_level = min(max_unlocked_level + 1, 200)
			
		win_streak += 1
		AchievementManager.update_stat("total_wins", 1)
		AchievementManager.update_stat("win_streak", win_streak, false)
		if is_mastery:
			AchievementManager.update_stat("mastery_level", current_level, false)
		if not undo_used_in_match:
			AchievementManager.update_stat("wins_no_undo", 1)
		
		if current_mode == Mode.PV_P:
			AchievementManager.update_stat("pvp_matches", 1)
			
	else:
		win_streak = 0
		AchievementManager.update_stat("win_streak", 0, false)
		
	save_data()
	emit_signal("game_over", winner)

func is_on_board(r, c):
	return r >= 0 and r < 8 and c >= 0 and c < 8

func get_piece_at(r, c):
	if is_on_board(r, c):
		return board[r][c]
	return null

func set_piece_at(r, c, piece):
	if is_on_board(r, c):
		board[r][c] = piece

func has_moves(side):
	var state = _get_board_state()
	var moves = _get_all_sim_moves(state, side, must_jump, selected_piece)
	return moves.size() > 0

func switch_turn():
	current_turn = Side.AI if current_turn == Side.PLAYER else Side.PLAYER
	
	if not has_moves(current_turn):
		check_win_condition(Side.AI if current_turn == Side.PLAYER else Side.PLAYER)
		return

	emit_signal("turn_changed", current_turn)

	if current_mode == Mode.PV_AI and current_turn == Side.AI:
		await get_tree().create_timer(1.0).timeout
		play_ai_turn()

func play_ai_turn():
	if is_calculating: return
	var board_node = get_tree().root.find_child("Board", true, false)
	if not board_node: return
	
	is_calculating = true
	var depth = 2
	if match_ai_level > 60: depth = 3
	if match_ai_level > 110: depth = 4
	if match_ai_level > 160: depth = 5
	
	var current_state = _get_board_state()
	var result = _minimax(current_state, depth, -INF, INF, true, must_jump, selected_piece)
	var best_move = result.move
	
	if best_move and best_move.piece_node:
		board_node.execute_move(best_move.piece_node, best_move.to.x, best_move.to.y)
		is_calculating = false
	else:
		is_calculating = false
		check_win_condition(Side.PLAYER)

func _get_board_state():
	var state = []
	for r in range(8):
		var row = []
		for c in range(8):
			var p = board[r][c]
			if p:
				var side_val = p.side if p is Piece else p.get("side")
				var king_val = p.is_king if p is Piece else p.get("is_king")
				row.append({"side": side_val, "is_king": king_val, "node": p if p is Piece else null})
			else:
				row.append(null)
		state.append(row)
	return state

func _minimax(state, depth, alpha, beta, is_max, m_jump, m_piece):
	if depth == 0:
		return {"score": _evaluate_board(state), "move": null}
	
	var moves = _get_all_sim_moves(state, Side.AI if is_max else Side.PLAYER, m_jump, m_piece)
	if moves.size() == 0:
		return {"score": - 10000 if is_max else 10000, "move": null}
	
	var best_move = moves.pick_random()
	if is_max:
		var max_eval = - INF
		for move in moves:
			var next_state = _simulate_move(state, move)
			var eval = _minimax(next_state, depth - 1, alpha, beta, false, false, null).score
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
			var eval = _minimax(next_state, depth - 1, alpha, beta, true, false, null).score
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
			if p:
				var val = 10 if not p.is_king else 30
				if p.side == Side.AI: score += val
				else: score -= val
	return score

func _get_all_sim_moves(state, side, m_jump, m_piece):
	var all_moves = []
	var captures = []
	
	if m_jump and m_piece:
		var target_node = m_piece if typeof(m_piece) != TYPE_DICTIONARY else m_piece.get("node")
		for r in range(8):
			for c in range(8):
				var p = state[r][c]
				if p and p.get("node") == target_node:
					var m = _get_sim_legal_moves(state, r, c)
					for move in m:
						if move.is_capture: captures.append(move)
	else:
		for r in range(8):
			for c in range(8):
				var p = state[r][c]
				if p and p.side == side:
					var m = _get_sim_legal_moves(state, r, c)
					for move in m:
						if move.is_capture: captures.append(move)
						else: all_moves.append(move)
	
	if captures.size() > 0: return captures
	return all_moves

func _get_sim_legal_moves(state, r, c):
	var p = state[r][c]
	if not p: return []
	var moves = []
	var directions = [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]
	
	for d in directions:
		if p.is_king:
			var enemy_found = false
			for i in range(1, 8):
				var nr = r + d.x * i
				var nc = c + d.y * i
				if not is_on_board(nr, nc): break
				var other = state[nr][nc]
				if other == null:
					if not enemy_found: moves.append({"from": Vector2i(r, c), "to": Vector2i(nr, nc), "is_capture": false, "piece_node": p.node})
					else: moves.append({"from": Vector2i(r, c), "to": Vector2i(nr, nc), "is_capture": true, "piece_node": p.node})
				else:
					if other.side == p.side: break
					else:
						if enemy_found: break
						enemy_found = true
		else:
			var jump_r = r + d.x * 2
			var jump_c = c + d.y * 2
			if is_on_board(jump_r, jump_c):
				var mid_p = state[r + d.x][c + d.y]
				if mid_p and mid_p.side != p.side and state[jump_r][jump_c] == null:
					moves.append({"from": Vector2i(r, c), "to": Vector2i(jump_r, jump_c), "is_capture": true, "piece_node": p.node})
			
			var forward = (p.side == Side.AI and d.x > 0) or (p.side == Side.PLAYER and d.x < 0)
			if forward:
				if is_on_board(r + d.x, c + d.y) and state[r + d.x][c + d.y] == null:
					moves.append({"from": Vector2i(r, c), "to": Vector2i(r + d.x, c + d.y), "is_capture": false, "piece_node": p.node})
	return moves

func _simulate_move(state, move):
	var new_state = []
	for r in range(8): new_state.append(state[r].duplicate())
	var p = new_state[move.from.x][move.from.y]
	new_state[move.from.x][move.from.y] = null
	new_state[move.to.x][move.to.y] = p
	if move.is_capture:
		new_state[(move.from.x + move.to.x) / 2][(move.from.y + move.to.y) / 2] = null
	if not p.is_king:
		if (p.side == Side.AI and move.to.x == 7) or (p.side == Side.PLAYER and move.to.x == 0):
			var np = p.duplicate()
			np.is_king = true
			new_state[move.to.x][move.to.y] = np
	return new_state
