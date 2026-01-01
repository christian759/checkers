extends Control

@onready var coins_label = $TopBar/Layout/Coins/HBox/Label
@onready var gems_label = $TopBar/Layout/Gems/HBox/Label
@onready var hearts_label = $TopBar/Layout/Hearts/HBox/Label
@onready var turn_label = $TopBar/Layout/TurnIndicator
@onready var streak_label = $TopBar/Layout/Streak/Label

func _ready():
	# Initially hide streak if 0
	_update_streak(GameManager.win_streak)

func update_coins(amount):
	coins_label.text = str(amount)
	_animate_ping(coins_label.get_parent())

func update_gems(amount):
	gems_label.text = str(amount)
	_animate_ping(gems_label.get_parent())

func update_hearts(amount):
	hearts_label.text = str(amount)
	_animate_ping(hearts_label.get_parent())

func _update_streak(amount):
	streak_label.text = "🔥 " + str(amount)
	streak_label.get_parent().visible = amount > 0

func _animate_ping(node):
	var tween = create_tween()
	tween.tween_property(node, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(node, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_ELASTIC)
