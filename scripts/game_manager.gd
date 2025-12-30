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
	setup_board()
	# This will be populated by the Board scene

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

	# Priority: captures, then random move
	if possible_captures.size() > 0:
		var move = possible_captures.pick_random()
		board_node.execute_move(move.piece, move.to.x, move.to.y)
	elif possible_moves.size() > 0:
		var move = possible_moves.pick_random()
		board_node.execute_move(move.piece, move.to.x, move.to.y)
	else:
		# No moves left? Game over.
		emit_signal("game_over", Side.PLAYER)
