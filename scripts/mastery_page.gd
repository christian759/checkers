extends Control

@onready var scroll_container = $VBoxContainer/ScrollContainer
@onready var card_container = $VBoxContainer/ScrollContainer/MarginContainer/HBoxContainer
@onready var global_progress = %ProgressLabel

var card_scene = preload("res://scenes/mastery_card.tscn")
var is_scrolling = false

var ranks = [
	{"name": "SPROUT", "color": Color("#2ecc71")}, # Emerald
	{"name": "BREEZE", "color": Color("#3498db")}, # Blue
	{"name": "EMBER", "color": Color("#e67e22")}, # Orange
	{"name": "STORM", "color": Color("#9b59b6")}, # Purple
	{"name": "ROYAL", "color": Color("#f1c40f")}, # Gold
	{"name": "ABYSS", "color": Color("#34495e")}, # Navy
	{"name": "ZENITH", "color": Color("#e74c3c")}, # Red
	{"name": "ETERNAL", "color": Color("#95a5a6")}, # Silver
	{"name": "LEGEND", "color": Color("#1abc9c")}, # Turquoise
	{"name": "DIVINE", "color": Color("#ffffff")} # White
]

func _ready():
	_clear_cards()
	populate_cards()
	
	var completed_total = GameManager.completed_levels.size()
	if global_progress:
		global_progress.text = "PROGRESS: " + str(completed_total) + "/200 LEVELS"
	
	# Initial centering on the furthest progress rank
	var current_rank_idx = clamp(floor((GameManager.max_unlocked_level - 1) / 20.0), 0, ranks.size() - 1)
	call_deferred("_center_initial_card", current_rank_idx)

func _clear_cards():
	if card_container:
		for child in card_container.get_children():
			child.queue_free()

func populate_cards():
	if not card_container: return
	for i in range(ranks.size()):
		var rank = ranks[i]
		var card = card_scene.instantiate()
		card_container.add_child(card)
		card.setup(rank.name, (i * 20) + 1, rank.color)

func _center_initial_card(index):
	if not card_container or card_container.get_child_count() <= index:
		return
		
	var target_card = card_container.get_child(index)
	# Position relative to MarginContainer (the scroll content)
	var card_x = target_card.position.x + card_container.position.x
	var scroll_center = scroll_container.size.x / 2.0
	var target_scroll = card_x - scroll_center + target_card.size.x / 2.0
	
	# Clamp target scroll
	var max_scroll = card_container.size.x - scroll_container.size.x
	target_scroll = clamp(target_scroll, 0, max_scroll)
	
	scroll_container.scroll_horizontal = int(target_scroll)
