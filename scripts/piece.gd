extends Node2D

class_name Piece

@export var side = GameManager.Side.NONE
@export var is_king = false

var grid_pos = Vector2i.ZERO

@onready var sprite = $Sprite
@onready var shadow = $Shadow
@onready var stack_sprite = $StackSprite
@onready var king_crown = $KingCrown
@onready var aura = $Aura

func _ready():
	update_visuals()

func _process(delta):
	if is_king and aura.visible:
		aura.rotate(delta * 2.0)

func update_visuals():
	if side == GameManager.Side.PLAYER:
		sprite.texture = load("res://assets/textures/piece_player.svg")
	elif side == GameManager.Side.AI:
		sprite.texture = load("res://assets/textures/piece_ai.svg")
	
	sprite.modulate = Color(1, 1, 1)
	shadow.texture = sprite.texture
	stack_sprite.texture = sprite.texture
	
	sprite.scale = Vector2(0.5, 0.5)
	shadow.scale = Vector2(0.5, 0.5)
	
	if is_king:
		stack_sprite.show()
		king_crown.show()
		aura.show()
		# Make king piece more vibrant/metallic
		sprite.modulate = Color(1.1, 1.1, 1.1)
		stack_sprite.modulate = Color(1.1, 1.1, 1.1)
	else:
		stack_sprite.hide()
		king_crown.hide()
		aura.hide()

func move_to(new_grid_pos: Vector2i, target_pos: Vector2):
	grid_pos = new_grid_pos
	
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
	
	# Play a "Royal" transformation animation
	var tween = create_tween().set_parallel(true)
	
	# Grow and bounce
	tween.tween_property(self, "scale", Vector2(1.6, 1.6), 0.3).set_trans(Tween.TRANS_BACK)
	
	# Animate the crown appearing
	if king_crown:
		king_crown.scale = Vector2.ZERO
		tween.tween_property(king_crown, "scale", Vector2(0.8, 0.8), 0.5).set_trans(Tween.TRANS_ELASTIC)
	
	# Animate the aura fade in
	aura.modulate.a = 0
	tween.tween_property(aura, "modulate:a", 1.0, 0.5)
	
	# Return to normal scale after peak
	var sequence = create_tween()
	sequence.tween_interval(0.3)
	sequence.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE)

func selected_anim(selected: bool):
	var tween = create_tween()
	if selected:
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.15).set_trans(Tween.TRANS_SINE)
		sprite.self_modulate = Color(1.2, 1.2, 1.2) # Slight glow
	else:
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_SINE)
		sprite.self_modulate = Color(1, 1, 1)
