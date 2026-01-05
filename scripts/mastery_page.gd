extends Control

@onready var scroll_container = $VBoxContainer/ScrollContainer
@onready var card_container = $VBoxContainer/ScrollContainer/MarginContainer/HBoxContainer
@onready var global_progress = $VBoxContainer/Header/ProgressLabel

var card_scene = preload("res://scenes/mastery_card.tscn")
var is_scrolling = false
var snap_speed = 10.0

var ranks = [
	{"name": "SPROUT", "color": Color("#d5f5e3")},
	{"name": "LEAF", "color": Color("#abebc6")},
	{"name": "SEEDLING", "color": Color("#82e0aa")},
	{"name": "VINE", "color": Color("#58d68d")},
	{"name": "EMERALD", "color": Color("#2ecc71")},
	{"name": "JADE", "color": Color("#28b463")},
	{"name": "FOREST", "color": Color("#239b56")},
	{"name": "ANCIENT", "color": Color("#1d8348")},
	{"name": "MYTHIC", "color": Color("#186a3e")},
	{"name": "IMMORTAL", "color": Color("#0e311f")}
]

func _ready():
	var completed_total = GameManager.completed_levels.size()
	global_progress.text = "OVERALL PROGRESS: " + str(completed_total) + "/200"
	global_progress.add_theme_color_override("font_color", Color("#2c3e50")) # Dark Slate
	
	populate_cards(GameManager.current_level)
	
	scroll_container.get_h_scroll_bar().changed.connect(_on_scroll_changed)
	call_deferred("_center_initial_card", 1) # Start at first rank (Sprout)

func populate_cards(current_level: int):
	for i in range(ranks.size()):
		var rank = ranks[i]
		var card = card_scene.instantiate()
		card_container.add_child(card)
		card.setup(rank.name, (i * 20) + 1, rank.color, current_level)

func _process(delta):
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not is_scrolling:
		_handle_snapping(delta)

func _on_scroll_changed():
	is_scrolling = true
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(func(): is_scrolling = false)

func _handle_snapping(delta):
	var scroll_x = scroll_container.scroll_horizontal
	var viewport_width = scroll_container.size.x
	var center_x = scroll_x + viewport_width / 2.0
	
	var best_card = null
	var min_dist = INF
	
	for card in card_container.get_children():
		var card_center = card.position.x + card.size.x / 2.0
		var dist = abs(center_x - card_center)
		if dist < min_dist:
			min_dist = dist
			best_card = card
	
	if best_card:
		var target_scroll = (best_card.global_position.x + scroll_x) - (viewport_width - best_card.size.x) / 2.0
		# Adjust for container offset
		target_scroll -= scroll_container.global_position.x
		scroll_container.scroll_horizontal = lerp(float(scroll_x), float(target_scroll), snap_speed * delta)

func _center_initial_card(level: int):
	var card_index = min(floor((level - 1) / 20.0), ranks.size() - 1)
	if card_index < card_container.get_child_count():
		var card = card_container.get_child(card_index)
		await get_tree().process_frame # Extra frame for layout stability
		var viewport_width = scroll_container.size.x
		var target_scroll = card.position.x - (viewport_width - card.size.x) / 2.0
		scroll_container.scroll_horizontal = target_scroll
