extends Node2D

class_name Piece

@export var side = GameManager.Side.NONE
@export var is_king = false

var grid_pos = Vector2i.ZERO

@onready var sprite = $Sprite
@onready var shadow = $Shadow

func _ready():
	update_visuals()

func update_visuals():
	if side == GameManager.Side.PLAYER:
		sprite.texture = load("res://assets/textures/piece_player.svg")
		shadow.texture = sprite.texture
		modulate = Color(1, 1, 1) # Reset modulation for player
	elif side == GameManager.Side.AI:
		sprite.texture = load("res://assets/textures/piece_ai.svg")
		shadow.texture = sprite.texture
		modulate = Color(1, 1, 1) # Reset modulation for AI
	
	sprite.scale = Vector2(0.5, 0.5)
	shadow.scale = Vector2(0.5, 0.5)
	
	if is_king:
		$KingIcon.show()
	else:
		$KingIcon.hide()

func move_to(new_grid_pos: Vector2i, target_pos: Vector2):
	grid_pos = new_grid_pos
	
	# Squash and stretch animation
	var tween = create_tween().set_parallel(false)
	
	# Jump up
	tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.1)
	tween.tween_property(self, "position", target_pos, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Land with squash
	tween.tween_property(self, "scale", Vector2(0.8, 1.2), 0.05)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_ELASTIC)

func promote_to_king():
	is_king = true
	update_visuals()
	# Play a little "pop" animation
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_ELASTIC)

func selected_anim(selected: bool):
	var tween = create_tween()
	if selected:
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
		# Add a soft glow or shadow change here
	else:
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
