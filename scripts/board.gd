extends Node2D

var tile_size = 85.0
var board_scale = 1.0

@onready var tile_container = $Tiles
@onready var piece_container = $Pieces
@onready var highlights = $Highlights

var piece_scene = preload("res://scenes/piece.tscn")
var marker_script = preload("res://scripts/move_marker.gd")

func _ready():
	GameManager.turn_changed.connect(_on_turn_changed)
	_setup_responsive_size()
	generate_board()
	
	if GameManager.is_daily_challenge:
		load_puzzle(GameManager.current_puzzle_id)
	else:
		spawn_pieces()
	
	if has_node("UI/QuitButton"):
		$UI/QuitButton.pressed.connect(func():
			GameManager.is_daily_challenge = false
			get_tree().change_scene_to_file("res://scenes/main.tscn")
		)
	
	# Handle first turn if it's AI
	if GameManager.current_turn == GameManager.Side.AI and GameManager.current_mode == GameManager.Mode.PV_AI:
		await get_tree().create_timer(1.0).timeout
		GameManager.play_ai_turn()

func load_puzzle(id):
	# Clear board logic
	GameManager.setup_board()
	
	var puzzle = null
	for p in GameManager.puzzles:
		if p.id == id:
			puzzle = p
			break
	
	if puzzle:
		for s in puzzle.setup:
			create_piece(s.r, s.c, s.side)
			if s.get("king", false):
				var p = GameManager.get_piece_at(s.r, s.c)
				if p: p.promote_to_king()

func _on_turn_changed(_side):
	call_deferred("check_game_over_condition")

func check_game_over_condition():
	if GameManager.current_mode == GameManager.Mode.PV_P:
		return
		
	if GameManager.current_turn == GameManager.Side.PLAYER:
		if not has_valid_moves(GameManager.Side.PLAYER):
			GameManager.check_win_condition(GameManager.Side.AI)
	else: # AI turn
		if not has_valid_moves(GameManager.Side.AI):
			if GameManager.is_daily_challenge:
				GameManager.complete_daily()
				# Show custom victory for daily
				GameManager.check_win_condition(GameManager.Side.PLAYER)
			else:
				GameManager.check_win_condition(GameManager.Side.PLAYER)
	
func has_valid_moves(side):
	for p in piece_container.get_children():
		if p.side == side:
			if get_legal_moves(p).size() > 0:
				return true
	return false

func _exit_tree():
	clear_highlights()

func rebuild_from_state(state):
	# Clear existing pieces
	for p in piece_container.get_children():
		p.queue_free()
	
	GameManager.setup_board() # Reset the logic array
	
	# Recreate pieces from state
	for r in range(8):
		for c in range(8):
			var s = state[r][c]
			if s:
				var p = piece_scene.instantiate()
				p.side = s.side
				p.grid_pos = s.grid_pos
				p.position = grid_to_world(p.grid_pos.x, p.grid_pos.y)
				piece_container.add_child(p)
				GameManager.set_piece_at(r, c, p)
				if s.is_king:
					p.promote_to_king()
	
	deselect_piece()

func _setup_responsive_size():
	var screen_width = get_viewport_rect().size.x
	# Target 90% of screen width
	var target_width = screen_width * 0.95
	tile_size = target_width / 8.0
	board_scale = 1.0 # We'll use the calculated tile_size directly
	
func generate_board():
	for r in range(8):
		for c in range(8):
			var is_dark = (r + c) % 2 == 1
			var tile = Panel.new()
			var gap = tile_size * 0.05
			tile.size = Vector2(tile_size - gap, tile_size - gap)
			tile.position = Vector2(c * tile_size + gap / 2.0, r * tile_size + gap / 2.0)
			
			var sb = StyleBoxFlat.new()
			sb.corner_radius_top_left = tile_size * 0.15
			sb.corner_radius_top_right = tile_size * 0.15
			sb.corner_radius_bottom_left = tile_size * 0.15
			sb.corner_radius_bottom_right = tile_size * 0.15
			
			if is_dark:
				sb.bg_color = GameManager.BOARD_THEMES[GameManager.board_theme_index].dark
			else:
				sb.bg_color = GameManager.BOARD_THEMES[GameManager.board_theme_index].light
				
			tile.add_theme_stylebox_override("panel", sb)
			tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tile_container.add_child(tile)

func spawn_pieces():
	# Standard layout
	for r in range(8):
		for c in range(8):
			var is_dark = (r + c) % 2 == 1
			if is_dark:
				if r < 3:
					create_piece(r, c, GameManager.Side.AI)
				elif r > 4:
					create_piece(r, c, GameManager.Side.PLAYER)

func create_piece(r, c, side):
	var p = piece_scene.instantiate()
	p.side = side
	p.grid_pos = Vector2i(r, c)
	p.position = grid_to_world(r, c)
	piece_container.add_child(p)
	GameManager.set_piece_at(r, c, p)

func grid_to_world(r, c):
	return Vector2(c * tile_size, r * tile_size) + Vector2(tile_size / 2.0, tile_size / 2.0)

func world_to_grid(pos):
	var local_pos = pos - global_position
	return Vector2i(floor(local_pos.y / tile_size), floor(local_pos.x / tile_size))

func _input(event):
	if GameManager.current_mode == GameManager.Mode.PV_AI:
		if GameManager.current_turn != GameManager.Side.PLAYER:
			return
	# In PvP, we just check if the clicked piece belongs to the current turn side later
		
	if event is InputEventMouseButton and event.pressed:
		var grid_pos = world_to_grid(get_global_mouse_position())
		if GameManager.is_on_board(grid_pos.x, grid_pos.y):
			handle_tile_click(grid_pos.x, grid_pos.y)

func handle_tile_click(r, c):
	var piece = GameManager.get_piece_at(r, c)
	
	# If we are in the middle of a multi-jump, only allow clicking the multi-jump piece
	if GameManager.must_jump:
		if piece == GameManager.selected_piece:
			select_piece(piece)
		elif GameManager.selected_piece:
			var valid_moves = get_legal_moves(GameManager.selected_piece)
			for move in valid_moves:
				if move.to == Vector2i(r, c):
					execute_move(GameManager.selected_piece, r, c)
					return
		return

	# Normal turn logic
	if piece and piece.side == GameManager.current_turn:
		if GameManager.forced_jumps:
			# Check if forced captures exist for this side
			var all_caps = get_all_captures(GameManager.current_turn)
			if all_caps.size() > 0:
				# Forced capture rule: only allow selecting pieces that can jump
				var can_jump = false
				for cap in all_caps:
					if cap.piece == piece:
						can_jump = true
						break
				if can_jump:
					select_piece(piece)
				else:
					deselect_piece()
			else:
				select_piece(piece)
		else:
			select_piece(piece)
	elif GameManager.selected_piece:
		var valid_moves = get_legal_moves(GameManager.selected_piece)
		var move_found = false
		for move in valid_moves:
			if move.to == Vector2i(r, c):
				execute_move(GameManager.selected_piece, r, c)
				move_found = true
				break
		
		if not move_found:
			deselect_piece()

func select_piece(piece):
	if GameManager.selected_piece and GameManager.selected_piece != piece:
		GameManager.selected_piece.selected_anim(false)
	
	GameManager.selected_piece = piece
	piece.selected_anim(true)
	show_valid_moves(piece)

func deselect_piece():
	if GameManager.selected_piece:
		GameManager.selected_piece.selected_anim(false)
	GameManager.selected_piece = null
	clear_highlights()

func show_valid_moves(piece):
	clear_highlights()
	
	if GameManager.current_mode == GameManager.Mode.PV_AI and piece.side == GameManager.Side.AI:
		return

	var moves = get_legal_moves(piece)
	
	# If forced capture exists for this side, filter out non-capture moves
	# (Though get_legal_moves already handles this if we call it correctly)
	var all_caps = get_all_captures(piece.side)
	if all_caps.size() > 0 and GameManager.forced_jumps:
		moves = moves.filter(func(m): return m.is_capture)

	for move in moves:
		var marker = Node2D.new()
		marker.set_script(marker_script)
		marker.position = grid_to_world(move.to.x, move.to.y)
		if move.is_capture:
			marker.modulate = Color(1.0, 0.5, 0.0) # ORANGE for capture (Visible on Green/White)
		else:
			marker.modulate = Color(0.0, 0.5, 1.0) # BLUE for normal (Visible on Green/White)
		highlights.add_child(marker)

func clear_highlights():
	for h in highlights.get_children():
		h.queue_free()

func get_legal_moves(piece: Piece):
	var moves = []
	var fr = piece.grid_pos.x
	var fc = piece.grid_pos.y
	
	var directions = []
	if GameManager.movement_mode == "diagonal":
		directions = [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]
	else:
		directions = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	
	# If NOT King, filter directions
	if not piece.is_king:
		var forward_dirs = []
		if GameManager.movement_mode == "diagonal":
			if piece.side == GameManager.Side.PLAYER:
				forward_dirs = [Vector2i(-1, -1), Vector2i(-1, 1)]
			else:
				forward_dirs = [Vector2i(1, -1), Vector2i(1, 1)]
		else:
			if piece.side == GameManager.Side.PLAYER:
				forward_dirs = [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(0, 1)]
			else:
				forward_dirs = [Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
		
		# Standard Piece Logic
		for d in directions:
			# Check capture (distance 2)
			var dest_r = fr + d.x * 2
			var dest_c = fc + d.y * 2
			var mid_r = fr + d.x
			var mid_c = fc + d.y
			
			if GameManager.is_on_board(dest_r, dest_c):
				var dest_p = GameManager.get_piece_at(dest_r, dest_c)
				var mid_p = GameManager.get_piece_at(mid_r, mid_c)
				
				if mid_p and mid_p.side != piece.side and dest_p == null:
					# Capture found
					# Rule: Men move/capture forward normally
					# EXCEPTION: If it is a "second kill" (multi-jump), they can capture backward
					var is_forward = false
					if piece.side == GameManager.Side.PLAYER:
						is_forward = (d.x < 0) # Moving UP (-1)
					else:
						is_forward = (d.x > 0) # Moving DOWN (+1)
					
					if is_forward:
						moves.append({"to": Vector2i(dest_r, dest_c), "is_capture": true})
					elif GameManager.must_jump:
						# Backward capture allowed ONLY if it's a multi-jump sequence
						moves.append({"to": Vector2i(dest_r, dest_c), "is_capture": true})

		# Check normal move (distance 1) - ONLY forward directions
		# Men can NEVER just move (non-capture) backward, even in multi-jump steps
		# (Captures can be backwards in International rules, usually?)
		# For simplicity, standard pieces capture in all directions (standard rule)? 
		# Actually English Draughts: men can only capture forward. International: backwards too.
		# Let's stick to: Men move/capture only forward (unless changed later).
		# Wait, code above checked ALL directions for capture. Let's keep that if that was intended.
		# But movement is restricted.
		
		if moves.size() == 0 or not GameManager.forced_jumps:
			for d in forward_dirs:
				var dest_r = fr + d.x
				var dest_c = fc + d.y
				if GameManager.is_on_board(dest_r, dest_c):
					if GameManager.get_piece_at(dest_r, dest_c) == null:
						moves.append({"to": Vector2i(dest_r, dest_c), "is_capture": false})

	else:
		# Flying King Logic
		for d in directions:
			var captured_piece = null
			for i in range(1, 8):
				var r = fr + d.x * i
				var c = fc + d.y * i
				
				if not GameManager.is_on_board(r, c): break
				
				var p = GameManager.get_piece_at(r, c)
				if p == null:
					if captured_piece == null:
						# Free move
						# Only add if allowed (e.g. if forced jumps is on, we might filter later)
						moves.append({"to": Vector2i(r, c), "is_capture": false})
					else:
						# Landing after capture
						moves.append({"to": Vector2i(r, c), "is_capture": true})
				else:
					if p.side == piece.side:
						break # Blocked by own piece
					else:
						if captured_piece == null:
							captured_piece = p # Found potential capture
						else:
							break # Blocked by second piece (cannot jump 2)
	
	return moves

func get_all_captures(side):
	var all_caps = []
	for r in range(8):
		for c in range(8):
			var p = GameManager.get_piece_at(r, c)
			if p and p.side == side:
				var moves = get_legal_moves(p)
				for m in moves:
					if m.is_capture:
						all_caps.append({"piece": p, "to": m.to, "is_capture": true})
	return all_caps

func is_valid_move(piece, destination_row, destination_col):
	var from_row = piece.grid_pos.x
	var from_col = piece.grid_pos.y
	
	var delta_row = destination_row - from_row
	var delta_col = destination_col - from_col
	
	# Basic diagonal check
	if abs(delta_row) != abs(delta_col): return false
	
	# Variable to hold move distance
	var move_distance = max(abs(delta_row), abs(delta_col))

	# Direction check (unless king or capturing)
	if not piece.is_king and move_distance == 1:
		if piece.side == GameManager.Side.PLAYER and delta_row >= 0: return false
		if piece.side == GameManager.Side.AI and delta_row <= 0: return false
	
	# Single step / Flying King empty move
	if move_distance == 1:
		return GameManager.get_piece_at(destination_row, destination_col) == null
		
	# Check path for obstructions
	if piece.is_king:
		var captured_piece = null
		var step_row = delta_row / move_distance
		var step_col = delta_col / move_distance
		
		# Check all squares in between
		for i in range(1, move_distance):
			var check_row = from_row + i * step_row
			var check_col = from_col + i * step_col
			var piece_at_check = GameManager.get_piece_at(check_row, check_col)
			
			if piece_at_check != null:
				if captured_piece != null: return false # Can't jump two pieces
				if piece_at_check.side == piece.side: return false # Can't jump own piece
				captured_piece = piece_at_check # Found an enemy to capture
		
		# Destination must be empty
		if GameManager.get_piece_at(destination_row, destination_col) != null: return false
		
		# If we found a piece, it's a capture move. If not, it's just a long move.
		return true

	# Standard piece jump step
	if move_distance == 2:
		if GameManager.get_piece_at(destination_row, destination_col) != null: return false
		var mid_row = (from_row + destination_row) / 2
		var mid_col = (from_col + destination_col) / 2
		var mid_piece = GameManager.get_piece_at(mid_row, mid_col)
		if mid_piece and mid_piece.side != piece.side:
			return true
			
	return false

func execute_move(piece, destination_row, destination_col):
	var from_row = piece.grid_pos.x
	var from_col = piece.grid_pos.y
	
	var delta_row = destination_row - from_row
	var delta_col = destination_col - from_col
	var move_distance = max(abs(delta_row), abs(delta_col)) # Use max for straight/diagonal consistency
	
	var is_capture = false
	var captured_piece = null
	
	# Detect capture by checking path
	var dir_row = delta_row / move_distance if move_distance > 0 else 0
	var dir_col = delta_col / move_distance if move_distance > 0 else 0
	
	for i in range(1, move_distance):
		var check_row = from_row + dir_row * i
		var check_col = from_col + dir_col * i
		var piece_at_check = GameManager.get_piece_at(check_row, check_col)
		if piece_at_check != null and piece_at_check != piece:
			is_capture = true
			captured_piece = piece_at_check
			break
	
	if is_capture and captured_piece:
		var capture_row = captured_piece.grid_pos.x
		var capture_col = captured_piece.grid_pos.y
		GameManager.set_piece_at(capture_row, capture_col, null)
		captured_piece.queue_free()
	
	# Move logic
	GameManager.set_piece_at(from_row, from_col, null)
	GameManager.set_piece_at(destination_row, destination_col, piece)
	piece.move_to(Vector2i(destination_row, destination_col), grid_to_world(destination_row, destination_col))
	
	# King promotion
	var promoted = false
	if not piece.is_king:
		if (piece.side == GameManager.Side.PLAYER and destination_row == 0) or (piece.side == GameManager.Side.AI and destination_row == 7):
			piece.promote_to_king()
			promoted = true
	
	# Multi-jump logic
	if is_capture and not promoted:
		var extra_moves = get_legal_moves(piece)
		var has_more_caps = false
		for m in extra_moves:
			if m.is_capture:
				has_more_caps = true
				break
		
		if has_more_caps:
			GameManager.must_jump = true
			select_piece(piece)
			return # Don't switch turn
		
	GameManager.must_jump = false
	deselect_piece()
	GameManager.switch_turn()

func has_any_captures(piece):
	var r = piece.grid_pos.x
	var c = piece.grid_pos.y
	
	# Directions to check
	var directions = [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]
	
	for d in directions:
		if piece.is_king:
			# Scan outward
			for i in range(2, 8):
				var scan_r = r + d.x * i
				var scan_c = c + d.y * i
				if not GameManager.is_on_board(scan_r, scan_c): break
				if is_valid_move(piece, scan_r, scan_c):
					# Check if it's actually a capture move
					# We can reuse the logic we just wrote or simplify
					# A valid move of distance >= 2 for a king MIGHT be a capture
					# Let's peek for a piece in between
					var captured = false
					for k in range(1, i):
						if GameManager.get_piece_at(r + d.x * k, c + d.y * k) != null:
							captured = true
							break
					if captured: return true
		else:
			# Standard man capture (distance 2)
			var scan_r = r + d.x * 2
			var scan_c = c + d.y * 2
			if GameManager.is_on_board(scan_r, scan_c):
				if is_valid_move(piece, scan_r, scan_c):
					# is_valid_move for non-king distance 2 IS a capture check
					return true
	return false
