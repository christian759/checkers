class_name Piece
extends Node2D

@onready var king_crown = $KingCrown
@onready var shadow = $Shadow

var side = GameManager.Side.PLAYER
var is_king = false
var theme_data = null
var grid_pos = Vector2i.ZERO

func setup(p_side, p_is_king, p_theme):
	side = p_side
	is_king = p_is_king
	theme_data = p_theme
	
	king_crown.visible = is_king
	_update_visuals()

func promote_to_king():
	promote()

func promote():
	is_king = true
	king_crown.visible = true
	king_crown.modulate = Color.WHITE
	king_crown.scale = Vector2.ZERO
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(king_crown, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	_update_visuals()

func selected_anim(active: bool):
	set_highlight(active)

func set_highlight(active: bool):
	var target_scale = Vector2(1.15, 1.15) if active else Vector2(1.0, 1.0)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", target_scale, 0.2).set_trans(Tween.TRANS_SINE)
	
	if active:
		# Simple scale, no shadow lift for flat look
		pass
	else:
		pass

func move_to(new_grid_pos: Vector2i, target_pos: Vector2):
	grid_pos = new_grid_pos
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_pos, 0.3)

func _update_visuals():
	queue_redraw()

func _draw():
	# v8 Premium "Chip" Implementation
	var color = Color.WHITE
	var accent = GameManager.FOREST
	
	if side == GameManager.Side.PLAYER:
		color = Color("#FEFEFE") # Pure White
		accent = GameManager.FOREST # Use v8 Token as accent
	else:
		color = GameManager.FOREST # AI is Green
		accent = Color.WHITE
		
	# 1. Base (Flat Chip)
	draw_set_transform(Vector2.ZERO, 0, Vector2(1, 1))
	# Draw main body
	draw_circle(Vector2.ZERO, 34, color)
	
	# 2. Simple Border (Flat)
	# Draw a simple, clean border instead of 3D bevels
	if side == GameManager.Side.PLAYER:
		draw_arc(Vector2.ZERO, 34, 0, TAU, 64, GameManager.BORDER_SOFT, 2.0, true)
	else:
		draw_arc(Vector2.ZERO, 34, 0, TAU, 64, Color.WHITE, 2.0, true)
	
	# 3. Inner Detail
	if is_king:
		# Draw Crown Polygon
		var crown_pts = PackedVector2Array([
			Vector2(-12, 4), Vector2(-16, -6), Vector2(-8, -2), Vector2(0, -12),
			Vector2(8, -2), Vector2(16, -6), Vector2(12, 4), Vector2(0, 8)
		])
		draw_colored_polygon(crown_pts, accent)
		draw_polyline(crown_pts, accent.darkened(0.2), 1.5, true)
	else:
		# Standard Piece: Simple Dot or Ring
		draw_circle(Vector2.ZERO, 8, accent.lerp(color, 0.5))
