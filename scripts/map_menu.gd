extends Control

const LEVEL_NODE = preload("res://scenes/level_node.tscn")

@onready var scroll_container = $ScrollContainer
@onready var path_container = $ScrollContainer/PathContainer
@onready var path_line = $ScrollContainer/PathContainer/PathLine
@onready var hearts_label = $TopBar/HBox/Hearts/Label
@onready var gems_label = $TopBar/HBox/Gems/Label
@onready var coins_label = $TopBar/HBox/Coins/Label

func _ready():
	generate_map()
	update_ui()
	
	# Connect top and bottom bar buttons
	$TopBar/Settings.pressed.connect(_on_settings_pressed)
	$TopBar/Achievements.pressed.connect(_on_achievements_pressed)
	$BottomBar/HBox/Shop.pressed.connect(_on_shop_pressed)
	
	# Scroll to current level
	await get_tree().process_frame
	scroll_to_current_level()

func generate_map():
	# Clear existing
	for child in path_container.get_children():
		if child is Control and child.name != "Islands" and child.name != "PathLine":
			child.queue_free()
	
	path_line.clear_points()
	var levels_count = 80
	var points = []
	
	# We want level 1 at the bottom, level 80 at the top
	# Let's say each level takes 200px vertical space
	# Total height = 16000
	var spacing = 200
	var total_height = levels_count * spacing + 400
	path_container.custom_minimum_size = Vector2(0, total_height)
	
	for i in range(1, levels_count + 1):
		var node = LEVEL_NODE.instantiate()
		var btn = node.get_node("Button")
		btn.text = str(i)
		
		# Position from bottom up
		var y_pos = total_height - (i * spacing) - 200
		var x_offset = sin(i * 0.6) * 150 + cos(i * 0.3) * 50
		var pos = Vector2(x_offset + 360, y_pos) # Center at 360 (720/2)
		
		node.position = pos - Vector2(60, 60) # Center node
		points.append(pos)
		
		# Lock/Unlock logic
		if i > GameManager.max_unlocked_level:
			btn.disabled = true
			node.modulate = Color(0.7, 0.7, 0.7)
		else:
			btn.disabled = false
			btn.pressed.connect(_on_level_selected.bind(i))
			node.modulate = Color.WHITE
			
		# Current level indicator (Coffee icon)
		if i == GameManager.current_level:
			var indicator = TextureRect.new()
			indicator.texture = load("res://assets/ui/current_level_marker.png")
			indicator.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			indicator.custom_minimum_size = Vector2(80, 80)
			indicator.size = Vector2(80, 80)
			indicator.position = Vector2(100, -80) # Offset to side
			node.add_child(indicator)
			
			# Bouncy animation for indicator
			var tween = create_tween().set_loops()
			tween.tween_property(indicator, "position:y", -90, 0.6).set_trans(Tween.TRANS_SINE)
			tween.tween_property(indicator, "position:y", -80, 0.6).set_trans(Tween.TRANS_SINE)
		
		path_container.add_child(node)
	
	path_line.points = points

func update_ui():
	hearts_label.text = "FULL 5"
	gems_label.text = "60"
	coins_label.text = "2,100"

func _on_level_selected(level_id):
	GameManager.current_level = level_id
	GameManager.current_mode = GameManager.Mode.PV_AI
	SceneTransition.change_scene("res://scenes/main.tscn")

func _on_settings_pressed():
	# Open settings overlay or scene
	SceneTransition.change_scene("res://scenes/settings_menu.tscn")

func _on_achievements_pressed():
	SceneTransition.change_scene("res://scenes/achievements_menu.tscn")

func _on_shop_pressed():
	print("Shop not implemented")

func scroll_to_current_level():
	var spacing = 200
	var total_height = 80 * spacing + 400
	var safe_level = clampi(GameManager.current_level, 1, 80)
	var y_pos = total_height - (safe_level * spacing) - 200
	
	# Center in viewport (approx 1280 height)
	var viewport_mid = 1280 / 2
	scroll_container.scroll_vertical = y_pos - viewport_mid
