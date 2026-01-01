extends Control

@onready var list_container = $ScrollContainer/VBox

func _ready():
	_update_list()
	$TopBar/Back.pressed.connect(_on_back_pressed)

func _update_list():
	# Clear existing
	for child in list_container.get_children():
		child.queue_free()
	
	for id in AchievementManager.achievements:
		var data = AchievementManager.achievements[id]
		var item = PanelContainer.new()
		item.custom_minimum_size = Vector2(0, 100)
		
		# Style
		var sb = StyleBoxFlat.new()
		sb.corner_radius_top_left = 15
		sb.corner_radius_top_right = 15
		sb.corner_radius_bottom_left = 15
		sb.corner_radius_bottom_right = 15
		sb.content_margin_left = 20
		sb.content_margin_right = 20
		
		if data.unlocked:
			sb.bg_color = Color(0.345, 0.8, 0.0, 1.0) # Green
			sb.shadow_size = 4
		else:
			sb.bg_color = Color(0.2, 0.2, 0.2, 1.0) # Grey
			
		item.add_theme_stylebox_override("panel", sb)
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		
		var title = Label.new()
		title.text = data.title
		title.add_theme_font_size_override("font_size", 24)
		title.add_theme_color_override("font_color", Color.WHITE)
		
		var desc = Label.new()
		desc.text = data.desc
		desc.add_theme_font_size_override("font_size", 16)
		if data.unlocked:
			desc.add_theme_color_override("font_color", Color(0.9, 1.0, 0.9, 0.8))
		else:
			desc.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))
			
		vbox.add_child(title)
		vbox.add_child(desc)
		vbox.add_child(title)
		vbox.add_child(desc)
		# Don't add vbox to item yet, we will put it in main_hbox
		
		# Status Icon
		var status = Label.new()
		if data.unlocked:
			status.text = "✅"
		else:
			status.text = "🔒"
		status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		status.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		status.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL
		
		# Simple layout hack: put status in a physics-process agnostic overlay or just margin container
		# Actually let's use an HBox inside the item
		var main_hbox = HBoxContainer.new()
		main_hbox.add_child(vbox)
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		main_hbox.add_child(status)
		
		item.add_child(main_hbox)
		
		list_container.add_child(item)

func _on_back_pressed():
	SceneTransition.change_scene("res://scenes/map_menu.tscn")
