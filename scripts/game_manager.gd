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
var move_history = [] # Stack of {piece, from, to, captured_piece, promoted}

signal turn_changed(new_side)
signal game_over(winner)
signal piece_moved(from, to)
signal piece_captured(pos)

func _ready():
	setup_board()

func setup_board():
	board = []
	for r in range(8):
		var row = []
		for c in range(8):
			row.append(null)
		board.append(row)

func reset_game():
	current_turn = Side.PLAYER
	selected_piece = null
	must_jump = false
	move_history = []
	setup_board()
	# This will be populated by the Board scene

func check_win_condition(winner):
	if winner == Side.PLAYER:
		if current_level == max_unlocked_level and max_unlocked_level < 5:
			max_unlocked_level += 1
			# Save game logic here ideally

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
	
	if current_mode == Mode.PV_AI and current_turn == Side.AI:
		# Trigger AI logic after a short delay for "thinking"
		await get_tree().create_timer(1.0).timeout
		play_ai_turn()

func play_ai_turn():
	var board_node = get_tree().root.find_child("Board", true, false)
	if not board_node:
		switch_turn()
		return

	var possible_moves = []
	var possible_captures = []

	# Find all pieces for AI
	for r in range(8):
		for c in range(8):
			var p = get_piece_at(r, c)
			if p and p.side == Side.AI:
				# Check moves
				for dr in [-1, 1, -2, 2]:
					for dc in [-1, 1, -2, 2]:
						if abs(dr) != abs(dc): continue
						var tr = r + dr
						var tc = c + dc
						if is_on_board(tr, tc) and board_node.is_valid_move(p, tr, tc):
							if abs(dr) == 2:
								possible_captures.append({"piece": p, "to": Vector2i(tr, tc)})
							else:
								possible_moves.append({"piece": p, "to": Vector2i(tr, tc)})

	# Difficulty Logic
	if current_level == 1:
		# Random logic (Already implemented)
		var all_legal = possible_captures + possible_moves
		if all_legal.size() > 0:
			var move = all_legal.pick_random()
			board_node.execute_move(move.piece, move.to.x, move.to.y)
		else:
			emit_signal("game_over", Side.PLAYER)
			
	elif current_level <= 3:
		# Level 2-3: Priority captures, then random
		if possible_captures.size() > 0:
			var move = possible_captures.pick_random()
			board_node.execute_move(move.piece, move.to.x, move.to.y)
		elif possible_moves.size() > 0:
			var move = possible_moves.pick_random()
			board_node.execute_move(move.piece, move.to.x, move.to.y)
		else:
			emit_signal("game_over", Side.PLAYER)
			
	else:
		# Level 4 & 5: Heuristics
		# Priority: Captures -> King Checks -> Center Control -> Random
		if possible_captures.size() > 0:
			# If multiple captures, pick one that lands centrally or is a King
			var best_cap = possible_captures[0]
			var best_score = -100
			
			for move in possible_captures:
				var score = 0
				if move.piece.is_king: score += 10
				# Prefer center
				var dist_to_center = abs(move.to.x - 3.5) + abs(move.to.y - 3.5)
				score -= dist_to_center
				
				if score > best_score:
					best_score = score
					best_cap = move
			
			board_node.execute_move(best_cap.piece, best_cap.to.x, best_cap.to.y)
			
		elif possible_moves.size() > 0:
			var best_move = possible_moves[0]
			var best_score = -100
			
			for move in possible_moves:
				var score = 0
				# Level 5: Aggressive King promotion
				if current_level == 5:
					score += (move.to.x) # Move towards player side (higher row index is better for AI?) 
					# Wait, AI starts at top (0-2)? No, checking Setup:
					# AI is usually Top (0-2), Player Bottom (5-7).
					# So AI wants to increase ROW index to promote.
					if move.to.x == 7: score += 50 # Promotion incentive
				
				# Center control (Level 4+)
				var dist_to_center = abs(move.to.x - 3.5) + abs(move.to.y - 3.5)
				score -= dist_to_center
				
				if score > best_score:
					best_score = score
					best_move = move
					
			board_node.execute_move(best_move.piece, best_move.to.x, best_move.to.y)
		else:
			emit_signal("game_over", Side.PLAYER)
	
	# Handle multi-jump for AI
	if current_turn == Side.AI:
		await get_tree().create_timer(1.0).timeout
		play_ai_turn()
