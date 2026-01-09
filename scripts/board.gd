extends Node2D

var tile_size = 85.0
var board_scale = 1.0

@onready var tile_container = $Gameplay/Tiles
@onready var piece_container = $Gameplay/Pieces
@onready var highlights = $Gameplay/Highlights
@onready var gameplay = $Gameplay
@onready var board_frame = %BoardFrame
@onready var timer_label = %TimerLabel

@onready var p1_time_label = %P1Time
@onready var p2_time_label = %P2Time

var piece_scene = preload("res://scenes/piece.tscn")
var marker_script = preload("res://scripts/move_marker.gd")
var results_scene = preload("res://scenes/game_results.tscn")

func _ready():
	GameManager.turn_changed.connect(_on_turn_changed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.board_restored.connect(_on_board_restored)
	_setup_responsive_size()
	generate_board()
	_update_hud()
	
	if GameManager.is_daily_challenge:
		load_puzzle(GameManager.current_puzzle_id)
	else:
		spawn_pieces()
	
	if has_node("UI/Header/HBox/QuitButton"):
		$UI/Header/HBox/QuitButton.pressed.connect(func():
			GameManager.is_daily_challenge = false
			get_tree().change_scene_to_file("res://scenes/main.tscn")
		)
	
	if has_node("UI/Header/HBox/UndoButton"):
		%UndoButton.pressed.connect(GameManager.undo_move)

func _process(delta):
	_update_timer(delta)

func _update_timer(delta):
	if GameManager.game_start_time <= 0: return
	
	# Global Elapsed Timer
	var elapsed = (Time.get_ticks_msec() - GameManager.game_start_time) / 1000.0
	var mins = int(elapsed / 60.0)
	var secs = int(elapsed) % 60
	timer_label.text = "%02d:%02d" % [mins, secs]
	
	# Match Clocks
	if GameManager.match_time_limit > 0:
		if GameManager.current_turn == GameManager.Side.PLAYER:
			GameManager.player_time -= delta
			if GameManager.player_time <= 0:
				GameManager.player_time = 0
				GameManager.check_win_condition(GameManager.Side.AI)
		else:
			GameManager.opponent_time -= delta
			if GameManager.opponent_time <= 0:
				GameManager.opponent_time = 0
				GameManager.check_win_condition(GameManager.Side.PLAYER)
		
		# Update UI
		p1_time_label.text = _format_time(GameManager.player_time)
		p2_time_label.text = _format_time(GameManager.opponent_time)
	else:
		# Just show standard timer style or hide
		p1_time_label.text = "--:--"
		p2_time_label.text = "--:--"

func _format_time(seconds):
	var m = int(seconds / 60.0)
	var s = int(seconds) % 60
	return "%02d:%02d" % [m, s]

func _update_hud():
	if GameManager.is_daily_challenge:
		%ModeLabel.text = "DAILY LAB"
		%LevelLabel.text = "PUZZLE #" + str(GameManager.current_puzzle_id + 1)
	elif GameManager.is_mastery:
		%ModeLabel.text = "MASTERY"
		%LevelLabel.text = "LEVEL " + str(GameManager.current_level)
	else:
		%ModeLabel.text = "PVP MATCH"
		%LevelLabel.text = "LOCAL GAME"
	
	_update_turn_label(GameManager.current_turn)

func _on_turn_changed(side):
	_update_turn_label(side)

func _update_turn_label(side):
	var active_color = Color("#2ecc71") # Vibrant Green
	var inactive_color = Color("#7f8c8d") # Grey
	
	if side == GameManager.Side.PLAYER:
		%TurnLabel.text = "YOUR TURN"
		%TurnLabel.add_theme_color_override("font_color", active_color)
		p1_time_label.add_theme_color_override("font_color", active_color)
		p1_time_label.modulate.a = 1.0
		p2_time_label.add_theme_color_override("font_color", inactive_color)
		p2_time_label.modulate.a = 0.5
	else:
		if GameManager.current_mode == GameManager.Mode.PV_AI:
			%TurnLabel.text = "AI THINKING..."
		else:
			%TurnLabel.text = "OPPONENT'S TURN"
			
		%TurnLabel.add_theme_color_override("font_color", Color("#e67e22"))
		p2_time_label.add_theme_color_override("font_color", Color("#e67e22"))
		p2_time_label.modulate.a = 1.0
		p1_time_label.add_theme_color_override("font_color", inactive_color)
		p1_time_label.modulate.a = 0.5

func _on_game_over(winner):
	var results = results_scene.instantiate()
	$UI.add_child(results)
	results.setup(winner)

func _setup_responsive_size():
	var view_size = get_viewport_rect().size
	var target_width = view_size.x * 0.92
	tile_size = target_width / 8.0
	
	var board_total_size = tile_size * 8.0
	var margin_x = (view_size.x - board_total_size) / 2.0
	var margin_y = (view_size.y - board_total_size) / 2.6 # Offset slightly up for footer
	
	gameplay.position = Vector2(margin_x, margin_y)
	
	var frame_padding = 20.0
	board_frame.size = Vector2(board_total_size + frame_padding * 2, board_total_size + frame_padding * 2)
	board_frame.position = Vector2(-frame_padding, -frame_padding)

func load_puzzle(id):
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

func _exit_tree():
	clear_highlights()

func _on_board_restored():
	rebuild_from_state(GameManager.board)
	_update_hud()

func rebuild_from_state(state):
	for p in piece_container.get_children():
		p.queue_free()
	
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
	for r in range(8):
		for c in range(8):
			var is_dark = (r + c) % 2 == 1
			if is_dark:
				if r < 3: create_piece(r, c, GameManager.Side.AI)
				elif r > 4: create_piece(r, c, GameManager.Side.PLAYER)

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
	var local_pos = pos - gameplay.global_position
	return Vector2i(floor(local_pos.y / tile_size), floor(local_pos.x / tile_size))

func _input(event):
	if GameManager.is_calculating: return
	if GameManager.current_mode == GameManager.Mode.PV_AI and GameManager.current_turn != GameManager.Side.PLAYER: return
	if event is InputEventMouseButton and event.pressed:
		var grid_pos = world_to_grid(get_global_mouse_position())
		if GameManager.is_on_board(grid_pos.x, grid_pos.y):
			handle_tile_click(grid_pos.x, grid_pos.y)

func handle_tile_click(r, c):
	var piece = GameManager.get_piece_at(r, c)
	if GameManager.must_jump:
		if piece == GameManager.selected_piece:
			select_piece(piece)
		elif GameManager.selected_piece:
			var valid_moves = get_legal_moves(GameManager.selected_piece)
			for move in valid_moves:
				if move.to == Vector2i(r, c):
					GameManager.push_history()
					execute_move(GameManager.selected_piece, r, c)
					return
		return

	if piece and piece.side == GameManager.current_turn:
		select_piece(piece)
	elif GameManager.selected_piece:
		var valid_moves = get_legal_moves(GameManager.selected_piece)
		for move in valid_moves:
			if move.to == Vector2i(r, c):
				GameManager.push_history()
				execute_move(GameManager.selected_piece, r, c)
				return
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
	if GameManager.current_mode == GameManager.Mode.PV_AI and piece.side == GameManager.Side.AI: return
	var moves = get_legal_moves(piece)
	for move in moves:
		var marker = Node2D.new()
		marker.set_script(marker_script)
		marker.position = grid_to_world(move.to.x, move.to.y)
		marker.modulate = Color(1, 0.4, 0.2) if move.is_capture else Color.WHITE
		highlights.add_child(marker)

func clear_highlights():
	for h in highlights.get_children(): h.queue_free()

func get_legal_moves(piece: Piece):
	var moves = []
	var directions = [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]
	var fr = piece.grid_pos.x
	var fc = piece.grid_pos.y
	
	for d in directions:
		if piece.is_king:
			var captured_piece = null
			for i in range(1, 8):
				var nr = fr + d.x * i
				var nc = fc + d.y * i
				if not GameManager.is_on_board(nr, nc): break
				var p = GameManager.get_piece_at(nr, nc)
				if p == null:
					if captured_piece == null: moves.append({"to": Vector2i(nr, nc), "is_capture": false})
					else: moves.append({"to": Vector2i(nr, nc), "is_capture": true})
				else:
					if p.side == piece.side: break
					else:
						if captured_piece == null: captured_piece = p
						else: break
		else:
			var jump_r = fr + d.x * 2
			var jump_c = fc + d.y * 2
			var is_forward = (piece.side == GameManager.Side.PLAYER and d.x < 0) or (piece.side == GameManager.Side.AI and d.x > 0)
			
			if GameManager.is_on_board(jump_r, jump_c):
				var mid_p = GameManager.get_piece_at(fr + d.x, fc + d.y)
				if mid_p and mid_p.side != piece.side and GameManager.get_piece_at(jump_r, jump_c) == null:
					# NEW RULE: Restricted backward captures (only on multi-jump chain)
					if is_forward or GameManager.must_jump:
						moves.append({"to": Vector2i(jump_r, jump_c), "is_capture": true})
			
			if is_forward and not GameManager.must_jump:
				var dr = fr + d.x
				var dc = fc + d.y
				if GameManager.is_on_board(dr, dc) and GameManager.get_piece_at(dr, dc) == null:
					moves.append({"to": Vector2i(dr, dc), "is_capture": false})
	return moves

func execute_move(piece, destination_row, destination_col):
	var from_row = piece.grid_pos.x
	var from_col = piece.grid_pos.y
	var move_dist = max(abs(destination_row - from_row), abs(destination_col - from_col))
	var dir_row = (destination_row - from_row) / move_dist
	var dir_col = (destination_col - from_col) / move_dist
	
	var is_capture = false
	var captured_piece = null
	for i in range(1, move_dist):
		var p = GameManager.get_piece_at(from_row + dir_row * i, from_col + dir_col * i)
		if p and p != piece:
			is_capture = true
			captured_piece = p
			break
	
	if is_capture and captured_piece:
		GameManager.set_piece_at(captured_piece.grid_pos.x, captured_piece.grid_pos.y, null)
		captured_piece.queue_free()
	
	GameManager.set_piece_at(from_row, from_col, null)
	GameManager.set_piece_at(destination_row, destination_col, piece)
	piece.move_to(Vector2i(destination_row, destination_col), grid_to_world(destination_row, destination_col))
	
	var promoted = false
	if not piece.is_king:
		if (piece.side == GameManager.Side.PLAYER and destination_row == 0) or (piece.side == GameManager.Side.AI and destination_row == 7):
			piece.promote_to_king()
			promoted = true
	
	if is_capture and not promoted:
		var has_more = false
		for m in get_legal_moves(piece):
			if m.get("is_capture"): has_more = true; break
		if has_more:
			GameManager.must_jump = true
			select_piece(piece)
			return
			
	GameManager.must_jump = false
	deselect_piece()
	GameManager.switch_turn()
