extends Node2D

const TILE_SIZE = 80
const OFFSET = Vector2(TILE_SIZE/2, TILE_SIZE/2)

@onready var tile_container = $Tiles
@onready var piece_container = $Pieces
@onready var highlights = $Highlights

var piece_scene = preload("res://scenes/piece.tscn")

func _ready():
	generate_board()
	spawn_pieces()

func generate_board():
	for r in range(8):
		for c in range(8):
			var is_dark = (r + c) % 2 == 1
			var tile = Panel.new()
			tile.size = Vector2(TILE_SIZE - 4, TILE_SIZE - 4) # Small gap
			tile.position = Vector2(c * TILE_SIZE + 2, r * TILE_SIZE + 2)
			
			var sb = StyleBoxFlat.new()
			sb.corner_radius_top_left = 12
			sb.corner_radius_top_right = 12
			sb.corner_radius_bottom_left = 12
			sb.corner_radius_bottom_right = 12
			
			if is_dark:
				sb.bg_color = Color("#7abf36") # Vibrant Green (Duolingo-ish Dark)
			else:
				sb.bg_color = Color("#ffffff") # White/Cream
				
			tile.add_theme_stylebox_override("panel", sb)
			tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tile_container.add_child(tile)

func spawn_pieces():
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
	return Vector2(c * TILE_SIZE, r * TILE_SIZE) + OFFSET

func world_to_grid(pos):
	var local_pos = pos - global_position
	return Vector2i(floor(local_pos.y / TILE_SIZE), floor(local_pos.x / TILE_SIZE))

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
	
	# Allow selecting own pieces if it's your turn
	if piece and piece.side == GameManager.current_turn:
		select_piece(piece)
	elif GameManager.selected_piece:
		# Check if valid move
		if is_valid_move(GameManager.selected_piece, r, c):
			execute_move(GameManager.selected_piece, r, c)
		else:
			# Deselect if invalid click
			deselect_piece()

func select_piece(piece):
	if GameManager.selected_piece:
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
	# Simplified move logic for highlighting
	# In a real game, this would call is_valid_move for all neighbors
	pass

func clear_highlights():
	for h in highlights.get_children():
		h.queue_free()

func is_valid_move(piece, tr, tc):
	var fr = piece.grid_pos.x
	var fc = piece.grid_pos.y
	
	var dr = tr - fr
	var dc = tc - fc
	
	# Basic diagonal check
	if abs(dr) != abs(dc): return false
	
	# Direction check (unless king)
	if not piece.is_king:
		if piece.side == GameManager.Side.PLAYER and dr >= 0: return false
		if piece.side == GameManager.Side.AI and dr <= 0: return false
	
	# Single step / Flying King empty move
	var distance = abs(dr)
	if distance == 1:
		return GameManager.get_piece_at(tr, tc) == null
		
	# Check path for obstructions
	if piece.is_king:
		var captured = null
		var r_step = dr / distance
		var c_step = dc / distance
		
		# Check all squares in between
		for i in range(1, distance):
			var check_r = fr + i * r_step
			var check_c = fc + i * c_step
			var p = GameManager.get_piece_at(check_r, check_c)
			
			if p != null:
				if captured != null: return false # Can't jump two pieces
				if p.side == piece.side: return false # Can't jump own piece
				captured = p # Found an enemy to capture
		
		# Destination must be empty
		if GameManager.get_piece_at(tr, tc) != null: return false
		
		# If we found a piece, it's a capture move. If not, it's just a long move.
		# Note: In some rules, you MUST capture if possible.
		# For now, we return valid if it's a valid move or valid capture.
		return true

	# Standard piece jump step
	if distance == 2:
		if GameManager.get_piece_at(tr, tc) != null: return false
		var mid_r = (fr + tr) / 2
		var mid_c = (fc + tc) / 2
		var mid_piece = GameManager.get_piece_at(mid_r, mid_c)
		if mid_piece and mid_piece.side != piece.side:
			return true
			
	return false

func execute_move(piece, tr, tc):
	var fr = piece.grid_pos.x
	var fc = piece.grid_pos.y
	
	# Find if there was a capture
	var captured_piece = null
	var dr = tr - fr
	var dc = tc - fc
	var distance = abs(dr)
	
	if distance >= 2:
		var r_step = dr / distance
		var c_step = dc / distance
		for i in range(1, distance):
			var check_r = fr + i * r_step
			var check_c = fc + i * c_step
			var p = GameManager.get_piece_at(check_r, check_c)
			if p != null:
				captured_piece = p
				break
	
	# Check for capture
	if captured_piece:
		GameManager.set_piece_at(captured_piece.grid_pos.x, captured_piece.grid_pos.y, null)
		captured_piece.queue_free()
		AudioManager.play_sound("capture")
	
	# Move logic
	GameManager.set_piece_at(fr, fc, null)
	GameManager.set_piece_at(tr, tc, piece)
	piece.move_to(Vector2i(tr, tc), grid_to_world(tr, tc))
	AudioManager.play_sound("move")
	
	# King promotion
	var promoted = false
	if not piece.is_king:
		if (piece.side == GameManager.Side.PLAYER and tr == 0) or (piece.side == GameManager.Side.AI and tr == 7):
			piece.promote_to_king()
			promoted = true
	
	# Multi-jump logic
	if captured_piece and not promoted:
		if has_any_captures(piece):
			select_piece(piece)
			return # Don't switch turn
		
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
				var tr = r + d.x * i
				var tc = c + d.y * i
				if not GameManager.is_on_board(tr, tc): break
				if is_valid_move(piece, tr, tc):
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
			var tr = r + d.x * 2
			var tc = c + d.y * 2
			if GameManager.is_on_board(tr, tc):
				if is_valid_move(piece, tr, tc):
					# is_valid_move for non-king distance 2 IS a capture check
					return true
	return false
