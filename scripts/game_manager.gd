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

# Settings
var forced_jumps = false
var movement_mode = "diagonal" # "diagonal" or "straight"

signal turn_changed(new_side)
signal game_over(winner, next_level_possible)
signal piece_moved(from, to)
signal piece_captured(pos)
signal coins_changed(new_amount)
signal hearts_changed(new_amount)
signal board_theme_changed(theme_data)

const WIN_REWARD = 50
const MAX_HEARTS = 5

const BOARD_THEMES = [
	{"name": "CLASSIC", "light": Color("#f9f9f9"), "dark": Color("#2ecc71")},
	{"name": "OCEAN", "light": Color("#e0f7fa"), "dark": Color("#0277bd")},
	{"name": "FOREST", "light": Color("#dcedc8"), "dark": Color("#33691e")},
	{"name": "PINK", "light": Color("#f8bbd0"), "dark": Color("#c2185b")},
	{"name": "NIGHT", "light": Color("#cfcfcf"), "dark": Color("#202020")}
]

var coins = 0
var hearts = 5
var board_theme_index = 0

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


func check_win_condition(winner):
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
		# AI cannot move -> Player wins
		check_win_condition(Side.PLAYER)

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
		
	# Better AI: Find all best moves and pick random
	var best_moves = []
	var best_score = -100000
	
	for m in all_moves:
		var score = evaluate_move(board_node, m)
		
		# Add a small fuzzy factor to break score ties naturally
		score += randf_range(-0.5, 0.5)
		
		if score > best_score:
			best_score = score
			best_moves = [m]
		elif abs(score - best_score) < 0.1: # Treated as equal
			best_moves.append(m)
			
	if best_moves.size() > 0:
		return best_moves.pick_random()
		
	return all_moves.pick_random()

func evaluate_move(_board_node, move):
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
	
	# Randomness for all levels to ensure variety
	score += randf_range(0, 5)
		
	return score
