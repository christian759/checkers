extends Control

const TOTAL_LEVELS = 80
const LEVELS_PER_SEASON = 20
var selected_node_num = 1

@onready var journey = $ScrollContainer/Journey
@onready var scroll_container = $ScrollContainer

func _ready():
	_setup_ui()
	_generate_level_path()
	
	await get_tree().process_frame
	scroll_container.scroll_vertical = 999999

func _setup_ui():
	# Simple, minimalist header needs no specific signals yet
	pass

func _generate_level_path():
	for child in journey.get_children():
		child.queue_free()
		
	var island_scene = preload("res://scenes/island.tscn")
	
	for i in range(16): 
		var island = island_scene.instantiate()
		journey.add_child(island)
		journey.move_child(island, 0)
		
		var levels_data = []
		for j in range(5):
			var level_num = i * 5 + j + 1
			levels_data.append({"num": level_num})
		
		var season_idx = clamp(int(float(i * 5) / LEVELS_PER_SEASON), 0, 3)
		island.setup(season_idx, levels_data, self)

func _on_level_selected(level):
	selected_node_num = level
	_show_premium_modal()

func _show_premium_modal():
	var modal_layer = CanvasLayer.new()
	modal_layer.layer = 10
	add_child(modal_layer)
	
	var overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.5)
	modal_layer.add_child(overlay)
	
	# Using the regular Button style from theme for modal buttons
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(600, 700)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	modal_layer.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 60
	vbox.offset_top = 80
	vbox.offset_right = -60
	vbox.offset_bottom = -80
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constants_override("separation", 50)
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "LEVEL " + str(selected_node_num)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(title)
	
	var ai_btn = Button.new()
	ai_btn.text = "BATTLE AI"
	ai_btn.custom_minimum_size = Vector2(0, 120)
	ai_btn.pressed.connect(func(): _start_match(GameManager.Mode.PV_AI))
	vbox.add_child(ai_btn)
	
	var pvp_btn = Button.new()
	pvp_btn.text = "VERSUS"
	pvp_btn.custom_minimum_size = Vector2(0, 120)
	pvp_btn.pressed.connect(func(): _start_match(GameManager.Mode.PV_P))
	vbox.add_child(pvp_btn)
	
	var close_btn = Button.new()
	close_btn.text = "CANCEL"
	close_btn.flat = true
	close_btn.pressed.connect(func(): modal_layer.queue_free())
	vbox.add_child(close_btn)

func _start_match(mode):
	GameManager.reset_game()
	GameManager.current_level = selected_node_num
	GameManager.current_mode = mode
	SceneTransition.change_scene("res://scenes/main.tscn")
