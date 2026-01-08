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
var is_mastery = false # Track if current game is from Mastery levels
var daily_completed = false
var game_start_time = 0
var is_calculating = false # Lock input while AI thinks
var undo_used_in_match = false # Track for achievement
var active_theme_played = false # Track for achievement per match

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
<<<<<<< Updated upstream
<<<<<<< Updated upstream
var completed_daily_dates = [] # Array of date strings
var current_daily_date = "" # The specific date being played
=======
var completed_dailies = [] # Array of date strings "YYYY-MM-DD"
>>>>>>> Stashed changes
=======
var completed_dailies = [] # Array of date strings "YYYY-MM-DD"
>>>>>>> Stashed changes
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

# Emerald Minimalist Design Tokens (v8 Fresh)
const FOREST = Color("#10B981") # Vibrant Emerald 500 (Clean, modern)
const RED = Color("#EF4444") # Vibrant Red (Classic AI)
const MINT_SAGE = Color("#34D399") # Emerald 400 (Soft accent)
const MINT_LITE = Color("#D1FAE5") # Emerald 100 (Visible light green)
const BORDER_SOFT = Color("#10B981", 0.15)
const LARGE_RADIUS = 96.0
const MEDIUM_RADIUS = 40.0
const BG_COLOR = Color("#F0FDF4") # Emerald 50 (Very soft tint)

# Settings
var forced_jumps = false
var movement_mode = "diagonal" # "diagonal" or "straight"
var sound_enabled = true
var vibration_enabled = true

signal turn_changed(new_side)
signal game_over(winner) # Simplified signature for consistency
signal board_restored() # For refreshing UI after undo/load


const BOARD_THEMES = [
	{"name": "EMERALD", "light": Color("#f8fff9"), "dark": Color("#1b4332")},
	{"name": "OCEAN", "light": Color("#e0f7fa"), "dark": Color("#0277bd")},
	{"name": "FOREST", "light": Color("#dcedc8"), "dark": Color("#33691e")},
	{"name": "PINK", "light": Color("#fdf2f8"), "dark": Color("#9d174d")},
	{"name": "NIGHT", "light": Color("#e5e5e5"), "dark": Color("#171717")}
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
<<<<<<< Updated upstream
<<<<<<< Updated upstream
			"completed_daily_dates": completed_daily_dates
=======
			"completed_dailies": completed_dailies
>>>>>>> Stashed changes
=======
			"completed_dailies": completed_dailies
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
<<<<<<< Updated upstream
			completed_daily_dates = data.get("completed_daily_dates", [])
=======
			completed_dailies = data.get("completed_dailies", [])
>>>>>>> Stashed changes
=======
			completed_dailies = data.get("completed_dailies", [])
>>>>>>> Stashed changes

func setup_board():
	board = []
	for r in range(8):
		var row = []
		for c in range(8):
			row.append(null)
		board.append(row)

func complete_daily(date: String = ""):
	var target_date = date
	if target_date == "":
		target_date = Time.get_date_string_from_system()
		
	var today = Time.get_date_string_from_system()
	if last_daily_date != today and target_date == today:
		daily_streak += 1
		last_daily_date = today
<<<<<<< Updated upstream
<<<<<<< Updated upstream
	
	if not target_date in completed_daily_dates:
		completed_daily_dates.append(target_date)
=======
		if not today in completed_dailies:
			completed_dailies.append(today)
>>>>>>> Stashed changes
=======
		if not today in completed_dailies:
			completed_dailies.append(today)
>>>>>>> Stashed changes
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
	AchievementManager.add_theme_used(0) # Mastery always uses theme 0 (Classic)
	match_mode = Mode.PV_AI
	match_ai_level = level
	match_theme_index = 0 # Classic for Mastery
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
	# Store state BEFORE the move happens
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
				row.append({"side": p.side, "is_king": p.is_king, "grid_pos": p.grid_pos})
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
	# unless it's currently AI turn and we're undoing its half-finished move
	var steps = 2 if current_mode == Mode.PV_AI else 1
	if must_jump: steps = 1 # Only undo one jump if in middle of sequence
	
	for i in range(steps):
		if move_history.size() > 0:
			var snapshot = move_history.pop_back()
			_restore_snapshot(snapshot)
	
	emit_signal("board_restored")

func _restore_snapshot(snapshot):
	current_turn = snapshot.turn
	must_jump = snapshot.must_jump
	current_level = snapshot.level
	
	# Restore the logic board array
	for r in range(8):
		for c in range(8):
			var s = snapshot.board[r][c]
			if s:
				# We store the raw data, the Board script will recreate the nodes
				board[r][c] = s
			else:
				board[r][c] = null


func check_win_condition(winner):
	print("[DEBUG] Win condition triggered for: ", "PLAYER" if winner == Side.PLAYER else "AI")
	if winner == Side.PLAYER:
		if not current_level in completed_levels:
			completed_levels.append(current_level)
		
		if current_level == max_unlocked_level:
			max_unlocked_level = min(max_unlocked_level + 1, 200)
			
		win_streak += 1
		
		# Log Daily Completion
		if is_daily_challenge:
			complete_daily(current_daily_date)
		
		# Achievement Tracking
		AchievementManager.update_stat("total_wins", 1)
		AchievementManager.update_stat("win_streak", win_streak, false)
		if is_mastery:
			AchievementManager.update_stat("mastery_level", current_level, false)
		if not undo_used_in_match:
			AchievementManager.update_stat("wins_no_undo", 1)
			if is_mastery and current_level >= 50:
				AchievementManager.trigger_manual_achievement("level_50_no_undo")
		
		if current_mode == Mode.PV_P:
			AchievementManager.update_stat("pvp_matches", 1)
			
		# Theme stats
		var theme_keys = ["classic_played", "ocean_played", "forest_played", "pink_played", "night_played"]
		if board_theme_index < theme_keys.size():
			AchievementManager.update_stat(theme_keys[board_theme_index], 1)
			
		# Speed achievements
		var duration = (Time.get_ticks_msec() - game_start_time) / 1000.0
		if duration < 300: # 5 minutes
			AchievementManager.trigger_manual_achievement("fast_win")
		if duration > 900: # 15 minutes
			AchievementManager.trigger_manual_achievement("marathon")
			
	else:
		win_streak = 0
		AchievementManager.update_stat("win_streak", 0, false)
		
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

func has_moves(side):
	var state = _get_board_state()
	var moves = _get_all_sim_moves(state, side, must_jump, selected_piece)
	return moves.size() > 0

func switch_turn():
	current_turn = Side.AI if current_turn == Side.PLAYER else Side.PLAYER
	
	# Robust internal move check (No longer relies on Board node)
	if not has_moves(current_turn):
		# The player who just lost their turn's opponent wins
		check_win_condition(Side.AI if current_turn == Side.PLAYER else Side.PLAYER)
		return

	emit_signal("turn_changed", current_turn)

	if current_mode == Mode.PV_AI and current_turn == Side.AI:
		# Trigger AI logic after a short delay for "thinking"
		await get_tree().create_timer(1.0).timeout
		play_ai_turn()

func play_ai_turn():
	if is_calculating: return
	
	var board_node = get_tree().root.find_child("Board", true, false)
	if not board_node: return
	
	is_calculating = true

	# Refined depth mapping for smooth progression
	var depth = 2
	if match_ai_level > 60: depth = 3
	if match_ai_level > 110: depth = 4
	if match_ai_level > 160: depth = 5
	if match_ai_level > 190: depth = 7
	
	# Tiers of "Stupidity" (Blunders) for low levels
	var rand_val = randf()
	var use_random = false
	if match_ai_level <= 10: # Very Dumb
		if rand_val < 0.85: use_random = true
	elif match_ai_level <= 30: # Novice
		if rand_val < 0.5: use_random = true
	elif match_ai_level <= 50: # Apprentice
		if rand_val < 0.2: use_random = true
	
	var current_state = _get_board_state()
	var best_move = null
	
	if use_random:
		var moves = _get_all_sim_moves(current_state, Side.AI, must_jump, selected_piece)
		if moves.size() > 0:
			best_move = moves.pick_random()
	else:
		var result = _minimax(current_state, depth, -INF, INF, true, must_jump, selected_piece)
		best_move = result.move
	
	if best_move and best_move.piece_node:
		board_node.execute_move(best_move.piece_node, best_move.to.x, best_move.to.y)
		
		if must_jump:
			is_calculating = false # Briefly unlock for the timer
			await get_tree().create_timer(0.6).timeout
			play_ai_turn()
		else:
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
				row.append({"side": p.side, "is_king": p.is_king, "node": p})
			else:
				row.append(null)
		state.append(row)
	return state

func _minimax(state, depth, alpha, beta, is_max, m_jump, m_piece):
	if depth == 0:
		return {"score": _evaluate_board(state), "move": null}
	
	var moves = _get_all_sim_moves(state, Side.AI if is_max else Side.PLAYER, m_jump, m_piece)
	
	# Move Sorting: Prioritize captures to optimize Alpha-Beta pruning
	moves.sort_custom(func(a, b): return a.is_capture and not b.is_capture)
	
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
	var ai_pieces = []
	var player_pieces = []
	
	for r in range(8):
		for c in range(8):
			var p = state[r][c]
			if not p: continue
			
			if p.side == Side.AI: ai_pieces.append({"r": r, "c": c, "p": p})
			else: player_pieces.append({"r": r, "c": c, "p": p})
			
			var multiplier = 1 if p.side == Side.AI else -1
			# Higher value for Kings
			var val = 10 if not p.is_king else 35
			
			# Advancement Bonus: Reward pieces moving forward
			if not p.is_king:
				if p.side == Side.AI: val += r * 1.5 # AI wants to go to row 7
				else: val += (7 - r) * 1.5 # Player wants to go to row 0
			
			# Back Row Defense: Strong reward for keeping base row filled
			if p.side == Side.AI and r == 0: val += 8
			if p.side == Side.PLAYER and r == 7: val += 8
			
			# Center Control (Power Squares: 3,4 and 2,5)
			var center_bonus = 0
			if r >= 2 and r <= 5 and c >= 2 and c <= 5:
				center_bonus = 4
				if r >= 3 and r <= 4 and c >= 3 and c <= 4:
					center_bonus = 6
			val += center_bonus
			
			score += val * multiplier

	# Endgame "Hunter" logic: AI gets aggressive if winning
	if ai_pieces.size() > 0 and player_pieces.size() > 0:
		if ai_pieces.size() > player_pieces.size() + 2:
			# Find min distance to closest enemy for each AI king
			for ai_p in ai_pieces:
				if ai_p.p.is_king:
					var min_dist = 100
					for pl_p in player_pieces:
						var d = abs(ai_p.r - pl_p.r) + abs(ai_p.c - pl_p.c)
						if d < min_dist: min_dist = d
					# Penalty for distance: closer is better
					score += (14 - min_dist) * 2
	
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
