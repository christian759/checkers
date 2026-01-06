extends Control

@onready var scroll_container = $VBoxContainer/ScrollContainer
@onready var card_container = $VBoxContainer/ScrollContainer/MarginContainer/HBoxContainer
@onready var global_progress = %ProgressLabel

var card_scene = preload("res://scenes/mastery_card.tscn")
var is_scrolling = false
var snap_speed = 10.0

var ranks = [
	{"name": "MIST", "color": Color("#E0F7FA")},
	{"name": "DEEP", "color": Color("#80DEEA")},
	{"name": "AZURE", "color": Color("#4DD0E1")},
	{"name": "SAPPHIRE", "color": Color("#00ACC1")},
	{"name": "COBALT", "color": Color("#0097A7")},
	{"name": "CYBER", "color": Color("#00F2FF")},
	{"name": "VOID", "color": Color("#006064")},
	{"name": "OBSIDIAN", "color": Color("#004D40")},
	{"name": "SILK", "color": Color("#002621")},
	{"name": "ZENITH", "color": Color("#000000")}
]

func _ready():
	var completed_total = GameManager.completed_levels.size()
	global_progress.text = "OVERALL PROGRESS: " + str(completed_total) + "/200"
	global_progress.add_theme_color_override("font_color", GameManager.FOREST)
	
	populate_cards(GameManager.max_unlocked_level)
	
	scroll_container.get_h_scroll_bar().changed.connect(_on_scroll_changed)
	call_deferred("_center_initial_card", GameManager.max_unlocked_level)
	
	if has_node("%JumpToCurrentBtn"):
		%JumpToCurrentBtn.pressed.connect(func(): _center_initial_card(GameManager.max_unlocked_level))

func populate_cards(current_level: int):
	for i in range(ranks.size()):
		var rank = ranks[i]
		var card = card_scene.instantiate()
		card_container.add_child(card)
		card.setup(rank.name, (i * 20) + 1, rank.color, current_level)

var last_scroll_h = 0.0
var scroll_vel = 0.0

func _process(delta):
	var curr_h = scroll_container.scroll_horizontal
	scroll_vel = abs(curr_h - last_scroll_h)
	last_scroll_h = curr_h
	
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not is_scrolling:
		if scroll_vel < 5.0: # Snappier threshold
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
		var card_center = card.position.x + card.size.x / 2.0 + 60
		var dist = abs(center_x - card_center)
		if dist < min_dist:
			min_dist = dist
			best_card = card
	
	if best_card:
		var target_scroll = card_container.position.x + best_card.position.x - (viewport_width - best_card.size.x) / 2.0
		scroll_container.scroll_horizontal = lerp(float(scroll_x), float(target_scroll), 15.0 * delta) # Faster snapping

func _center_initial_card(level: int):
	var card_index = min(floor((level - 1) / 20.0), ranks.size() - 1)
	if card_index < card_container.get_child_count():
		var card = card_container.get_child(card_index)
		await get_tree().process_frame
		var viewport_width = scroll_container.size.x
		var target_scroll = card.position.x - (viewport_width - card.size.x) / 2.0
		
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(scroll_container, "scroll_horizontal", target_scroll, 0.8)
