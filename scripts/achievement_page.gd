extends Control

@onready var list = %List
@onready var progress_label = %ProgressLabel

func _ready():
	AchievementManager.add_visited_menu("achievement")
	refresh_list()

func _add_item(title: String, desc: String, is_unlocked: bool, category: String):
	var panel = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color("#ffffff")
	sb.corner_radius_top_left = 24
	sb.corner_radius_top_right = 24
	sb.corner_radius_bottom_left = 24
	sb.corner_radius_bottom_right = 24
	sb.shadow_color = Color(0, 0, 0, 0.03)
	sb.shadow_size = 12
	sb.shadow_offset = Vector2(0, 4)
	
	panel.add_theme_stylebox_override("panel", sb)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	panel.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	margin.add_child(hbox)
	
	# Procedural Icon Node
	var icon_container = Control.new()
	icon_container.custom_minimum_size = Vector2(64, 64)
	icon_container.script = load("res://scripts/procedural_icon.gd")
	icon_container.set_meta("category", category)
	icon_container.set_meta("unlocked", is_unlocked)
	hbox.add_child(icon_container)
	
	var label_vbox = VBoxContainer.new()
	label_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	hbox.add_child(label_vbox)
	
	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", Color("#122A20") if is_unlocked else Color("#95A5A6"))
	label_vbox.add_child(title_label)
	
	var desc_label = Label.new()
	desc_label.text = desc
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 15)
	desc_label.add_theme_color_override("font_color", Color("#7F8C8D"))
	label_vbox.add_child(desc_label)
	
	list.add_child(panel)

func refresh_list():
	for child in list.get_children():
		child.queue_free()
	
	var all_achievements = AchievementManager.achievements
	var unlocked = AchievementManager.unlocked_achievements
	
	if progress_label:
		progress_label.text = str(unlocked.size()) + "/60 UNLOCKED"
	
	for id in all_achievements.keys():
		var data = all_achievements[id]
		var is_unlocked = id in unlocked
		_add_item(data.title, data.desc, is_unlocked, data.get("category", "skill"))
