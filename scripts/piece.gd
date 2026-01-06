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
	
	# No shine, just a gentle scale
	_update_visuals()

func selected_anim(active: bool):
	set_highlight(active)

func set_highlight(active: bool):
	var target_scale = Vector2(1.15, 1.15) if active else Vector2(1.0, 1.0)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", target_scale, 0.2).set_trans(Tween.TRANS_SINE)
	
	if active:
		# Subtle lift
		tween.tween_property(shadow, "position:y", 12, 0.2)
		tween.tween_property(shadow, "modulate:a", 0.3, 0.2)
	else:
		tween.tween_property(shadow, "position:y", 4, 0.2)
		tween.tween_property(shadow, "modulate:a", 0.1, 0.2)

func move_to(new_grid_pos: Vector2i, target_pos: Vector2):
	grid_pos = new_grid_pos
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_pos, 0.3)

func _update_visuals():
	queue_redraw()

func _draw():
	var current_theme = theme_data if theme_data else GameManager.BOARD_THEMES[GameManager.board_theme_index]
	var color = current_theme.light if side == GameManager.Side.PLAYER else current_theme.dark
	var border_color = Color.BLACK if side == GameManager.Side.AI else Color.WHITE
	
	# Clean Minimalist Piece
	# 1. Base Shadow
	draw_circle(Vector2(0, 4), 28, Color(0, 0, 0, 0.1))
	
	# 2. Outer Ring
	draw_circle(Vector2.ZERO, 30, border_color)
	
	# 3. Inner Body
	draw_circle(Vector2.ZERO, 26, color)
	
	# 4. Center Detail (Minimal)
	draw_arc(Vector2.ZERO, 15, 0, TAU, 32, border_color, 1.5)
