extends Node2D

@onready var king_crown = $KingCrown
@onready var shadow = $Shadow

var side = GameManager.Side.PLAYER
var is_king = false
var theme_data = null

func setup(p_side, p_is_king, p_theme):
	side = p_side
	is_king = p_is_king
	theme_data = p_theme
	
	king_crown.visible = is_king
	_update_visuals()

func _update_visuals():
	queue_redraw()

func _draw():
	var color = theme_data.light if side == GameManager.Side.PLAYER else theme_data.dark
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

func promote():
	is_king = true
	king_crown.visible = true
	king_crown.modulate = Color.WHITE
	king_crown.scale = Vector2.ZERO
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(king_crown, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# No shine, just a gentle scale
	_update_visuals()

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
