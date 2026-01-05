extends Control

@onready var list = %List
@onready var progress_label = %ProgressLabel

var item_scene = null

func _ready():
	# Create a simple item UI dynamically since we don't have a separate tscn yet
	# Alternatively, I can define it here.
	AchievementManager.add_visited_menu("achievement")
	refresh_list()

func refresh_list():
	for child in list.get_children():
		child.queue_free()
	
	var all_achievements = AchievementManager.achievements
	var unlocked = AchievementManager.unlocked_achievements
	
	progress_label.text = str(unlocked.size()) + "/60 UNLOCKED"
	
	for id in all_achievements.keys():
		var data = all_achievements[id]
		var is_unlocked = id in unlocked
		_add_item(data.title, data.desc, is_unlocked)

func _add_item(title: String, desc: String, is_unlocked: bool):
	var panel = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color("#ffffff") if is_unlocked else Color("#f0f0f0")
	sb.corner_radius_top_left = 15
	sb.corner_radius_top_right = 15
	sb.corner_radius_bottom_left = 15
	sb.corner_radius_bottom_right = 15
	sb.shadow_size = 2 if is_unlocked else 0
	sb.shadow_color = Color(0, 0, 0, 0.05)
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
	
	var icon_rect = ColorRect.new()
	icon_rect.custom_minimum_size = Vector2(50, 50)
	icon_rect.color = Color("#2ecc71") if is_unlocked else Color("#bdc3c7")
	hbox.add_child(icon_rect)
	
	var label_vbox = VBoxContainer.new()
	label_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	hbox.add_child(label_vbox)
	
	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", Color("#2c3e50") if is_unlocked else Color("#7f8c8d"))
	label_vbox.add_child(title_label)
	
	var desc_label = Label.new()
	desc_label.text = desc
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", Color("#7f8c8d"))
	label_vbox.add_child(desc_label)
	
	list.add_child(panel)
