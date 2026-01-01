extends Control

const TOTAL_LEVELS = 80
const LEVELS_PER_SEASON = 20
var selected_node_num = 1

@onready var journey = $World/ScrollContainer/Journey
@onready var scroll_container = $World/ScrollContainer

func _ready():
	_setup_ui()
	_generate_level_path()
	
	await get_tree().process_frame
	scroll_container.scroll_vertical = 999999

func _setup_ui():
	# Navigation
	$ForegroundUI/BottomNav/HBox/Tour.pressed.connect(func(): scroll_container.scroll_vertical = 999999)
	$ForegroundUI/BottomNav/HBox/Shop.pressed.connect(func(): print("Shop pressed - Coming soon!"))

func _generate_level_path():
	for child in journey.get_children():
		child.queue_free()
		
	var island_count = 16
	for i in range(island_count):
		var island = Control.new()
		island.custom_minimum_size = Vector2(720, 800)
		journey.add_child(island)
		journey.move_child(island, 0)
		
		var line = Line2D.new()
		line.width = 100
		line.default_color = Color("#8ee000") # Bright green
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		line.joint_mode = Line2D.LINE_JOINT_ROUND
		island.add_child(line)
		
		# Inner "gloss" for the path
		var line_top = Line2D.new()
		line_top.width = 60
		line_top.default_color = Color("#a6f000", 0.3)
		line_top.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line_top.end_cap_mode = Line2D.LINE_CAP_ROUND
		island.add_child(line_top)
		
		var points = []
		for j in range(5):
			var level_num = i * 5 + j + 1
			# Narrower winding for the Ribbon effect
			var progress = float(j) / 4.0
			var ox = sin(progress * PI + (i * PI * 0.5)) * 120.0 
			var pos = Vector2(360 + ox, 700 - j * 160)
			
			points.append(pos)
			_create_playful_node(island, pos, level_num)
			
		line.points = points
		line_top.points = points

func _create_playful_node(parent, pos, num):
	var node_btn = Button.new()
	node_btn.custom_minimum_size = Vector2(160, 160)
	node_btn.text = str(num)
	node_btn.theme_type_variation = "PathNode"
	node_btn.add_theme_font_size_override("font_size", 48)
	node_btn.position = pos - Vector2(80, 80)
	parent.add_child(node_btn)
	
	node_btn.pressed.connect(func(): _on_level_selected(num))
	
	# Current level bounce
	if num == GameManager.max_unlocked_level:
		var tween = create_tween().set_loops()
		tween.tween_property(node_btn, "scale", Vector2(1.1, 1.1), 0.5).set_trans(Tween.TRANS_SINE)
		tween.tween_property(node_btn, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_SINE)

func _on_level_selected(level):
	selected_node_num = level
	_show_playful_modal()

func _show_playful_modal():
	var modal_layer = CanvasLayer.new()
	modal_layer.layer = 10
	add_child(modal_layer)
	
	var overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.4)
	modal_layer.add_child(overlay)
	
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(550, 600)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	modal_layer.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 40
	vbox.offset_top = 40
	vbox.offset_right = -40
	vbox.offset_bottom = -40
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constants_override("separation", 30)
	panel.add_child(vbox)
	
	var label = Label.new()
	label.text = "LEVEL " + str(selected_node_num)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.BLACK)
	label.add_theme_font_size_override("font_size", 64)
	vbox.add_child(label)
	
	var ai_btn = Button.new()
	ai_btn.text = "SOLO"
	ai_btn.custom_minimum_size = Vector2(0, 100)
	ai_btn.pressed.connect(func(): _start_match(GameManager.Mode.PV_AI))
	vbox.add_child(ai_btn)
	
	var pvp_btn = Button.new()
	pvp_btn.text = "DUO"
	pvp_btn.custom_minimum_size = Vector2(0, 100)
	pvp_btn.pressed.connect(func(): _start_match(GameManager.Mode.PV_P))
	vbox.add_child(pvp_btn)
	
	var close_btn = Button.new()
	close_btn.text = "X"
	close_btn.flat = true
	close_btn.pressed.connect(func(): modal_layer.queue_free())
	vbox.add_child(close_btn)

func _start_match(mode):
	GameManager.reset_game()
	GameManager.current_level = selected_node_num
	GameManager.current_mode = mode
	SceneTransition.change_scene("res://scenes/main.tscn")
