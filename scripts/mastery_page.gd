extends Control

@onready var scroll_container = $VBoxContainer/ScrollContainer
@onready var card_container = $VBoxContainer/ScrollContainer/MarginContainer/HBoxContainer
@onready var global_progress = $VBoxContainer/Header/ProgressLabel

var card_scene = preload("res://scenes/mastery_card.tscn")
var is_scrolling = false
var snap_speed = 10.0

var ranks = [
	{"name": "SPROUT", "color": Color("#2ecc71")},
	{"name": "LEAF", "color": Color("#27ae60")},
	{"name": "SEEDLING", "color": Color("#1abc9c")},
	{"name": "VINE", "color": Color("#16a085")},
	{"name": "EMERALD", "color": Color("#2ecc71")},
	{"name": "JADE", "color": Color("#27ae60")},
	{"name": "FOREST", "color": Color("#1d8348")},
	{"name": "ANCIENT", "color": Color("#145a32")},
	{"name": "MYTHIC", "color": Color("#0e311f")},
	{"name": "IMMORTAL", "color": Color("#000000")}
]

func _ready():
	var completed_total = GameManager.completed_levels.size()
	global_progress.text = "PROGRESS: " + str(completed_total) + "/200 LEVELS"
	global_progress.add_theme_color_override("font_color", Color("#1d8348"))
	
	_clear_cards()
	populate_cards()
	
	scroll_container.get_h_scroll_bar().changed.connect(_on_scroll_changed)
	
	# Center on the latest unlocked level
	var current_rank_idx = clamp(floor((GameManager.max_unlocked_level - 1) / 20.0), 0, ranks.size() - 1)
	call_deferred("_center_initial_card", current_rank_idx)

func _clear_cards():
	for child in card_container.get_children():
		child.queue_free()

func populate_cards():
	for i in range(ranks.size()):
		var rank = ranks[i]
		var card = card_scene.instantiate()
		card_container.add_child(card)
		# Pass ONLY the rank data and the start level. 
		# Content (level states) will be handled inside card.setup()
		card.setup(rank.name, (i * 20) + 1, rank.color)

var last_scroll_h = 0.0
var scroll_vel = 0.0

func _process(delta):
	var curr_h = scroll_container.scroll_horizontal
	scroll_vel = abs(curr_h - last_scroll_h)
	last_scroll_h = curr_h
	
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not is_scrolling:
		if scroll_vel < 2.0: # Only snap when slow
			_handle_snapping(delta)

func _on_scroll_changed():
	is_scrolling = true
	var timer = get_tree().create_timer(0.05)
	timer.timeout.connect(func(): is_scrolling = false)

func _handle_snapping(delta):
	var scroll_x = scroll_container.scroll_horizontal
	var viewport_width = scroll_container.size.x
	var center_x = scroll_x + viewport_width / 2.0
	
	var best_card = null
	var min_dist = INF
	
	for card in card_container.get_children():
		var card_center = card.position.x + card.size.x / 2.0 + 60 # Account for margin
		var dist = abs(center_x - card_center)
		if dist < min_dist:
			min_dist = dist
			best_card = card
	
	if best_card:
		var target_scroll = card_container.position.x + best_card.position.x - (viewport_width - best_card.size.x) / 2.0
		scroll_container.scroll_horizontal = lerp(float(scroll_x), float(target_scroll), 12.0 * delta)

func _center_initial_card(index: int):
	if index < card_container.get_child_count():
		var card = card_container.get_child(index)
		await get_tree().process_frame
		var viewport_width = scroll_container.size.x
		var target_scroll = card.position.x - (viewport_width - card.size.x) / 2.0
		scroll_container.scroll_horizontal = target_scroll
