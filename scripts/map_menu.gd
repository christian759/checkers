extends Control

const LEVEL_NODE = preload("res://scenes/level_node.tscn")

@onready var scroll_container = $ScrollContainer
@onready var path_container = $ScrollContainer/PathContainer
@onready var hearts_label = $TopBar/HBox/Hearts/Label
@onready var gems_label = $TopBar/HBox/Gems/Label
@onready var coins_label = $TopBar/HBox/Coins/Label

func _ready():
	generate_map()
	update_ui()
	
	# Connect top and bottom bar buttons
	$TopBar/Settings.pressed.connect(_on_settings_pressed)
	$BottomBar/HBox/Shop.pressed.connect(_on_shop_pressed)
	
	# Scroll to current level
	await get_tree().process_frame
	scroll_to_current_level()

func generate_map():
	# Clear existing
	for child in path_container.get_children():
		child.queue_free()
	
	var levels_count = 80
	for i in range(1, levels_count + 1):
		var node = LEVEL_NODE.instantiate()
		var btn = node.get_node("Button")
		btn.text = str(i)
		
		# Alternating x-offset for zig-zag path
		var x_offset = sin(i * 0.8) * 120
		node.position = Vector2(x_offset, (i-1) * -160)
		
		# Lock/Unlock logic
		if i > GameManager.max_unlocked_level:
			btn.disabled = true
		else:
			btn.disabled = false
			btn.pressed.connect(_on_level_selected.bind(i))
			
		# Current level indicator (Coffee icon)
		if i == GameManager.current_level:
			var indicator = TextureRect.new()
			indicator.texture = load("res://assets/ui/current_level_marker.png")
			indicator.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			indicator.custom_minimum_size = Vector2(60, 60)
			indicator.size = Vector2(60, 60)
			indicator.position = Vector2(20, -50)
			node.add_child(indicator)
			
			# Bouncy animation for indicator
			var tween = create_tween().set_loops()
			tween.tween_property(indicator, "position:y", -60, 0.6).set_trans(Tween.TRANS_SINE)
			tween.tween_property(indicator, "position:y", -50, 0.6).set_trans(Tween.TRANS_SINE)
		
		path_container.add_child(node)

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

func _on_shop_pressed():
	print("Shop not implemented")

func scroll_to_current_level():
	# Simple scroll to the bottom/top based on current level
	# Path goes UP (negative y), so higher levels are at higher negative positions
	var target_y = (GameManager.current_level - 1) * -160
	# Adjust for viewport center
	# ... (Complex scroll logic, for now just jump)
	pass
