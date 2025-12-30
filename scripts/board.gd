extends Node2D

const TILE_SIZE = 64
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
				sb.bg_color = Color("#ebebeb")
			else:
				sb.bg_color = Color("#f7f7f7")
				
			tile.add_theme_stylebox_override("panel", sb)
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
	if GameManager.current_turn != GameManager.Side.PLAYER:
		return
		
	if event is InputEventMouseButton and event.pressed:
		var grid_pos = world_to_grid(get_global_mouse_position())
		if GameManager.is_on_board(grid_pos.x, grid_pos.y):
			handle_tile_click(grid_pos.x, grid_pos.y)

func handle_tile_click(r, c):
	var piece = GameManager.get_piece_at(r, c)
	
	if piece and piece.side == GameManager.Side.PLAYER:
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
	
	# Single step
	if abs(dr) == 1:
		return GameManager.get_piece_at(tr, tc) == null
		
	# Jump step
	if abs(dr) == 2:
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
	var was_capture = abs(tr - fr) == 2
	
	# Check for capture
	if was_capture:
		var mid_r = (fr + tr) / 2
		var mid_c = (fc + tc) / 2
		var mid_piece = GameManager.get_piece_at(mid_r, mid_c)
		GameManager.set_piece_at(mid_r, mid_c, null)
		mid_piece.queue_free()
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
	if was_capture and not promoted:
		if has_any_captures(piece):
			select_piece(piece)
			return # Don't switch turn
		
	deselect_piece()
	GameManager.switch_turn()

func has_any_captures(piece):
	var r = piece.grid_pos.x
	var c = piece.grid_pos.y
	for dr in [-2, 2]:
		for dc in [-2, 2]:
			if is_valid_move(piece, r + dr, c + dc):
				return true
	return false
