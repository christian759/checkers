extends Control

@onready var list = %List
@onready var progress_label = %ProgressLabel

var item_scene = null

func _ready():
	# Create a simple item UI dynamically since we don't have a separate tscn yet
	# Alternatively, I can define it here.
	AchievementManager.add_visited_menu("achievement")
	refresh_list()

func _add_item(title: String, desc: String, is_unlocked: bool, category: String):
	var panel = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color("#ffffff") if is_unlocked else Color("#e0e0e0")
	sb.border_width_left = 4
	sb.border_width_top = 4
	sb.border_width_right = 4
	sb.border_width_bottom = 4
	sb.border_color = Color(0, 0, 0, 1)
	sb.corner_radius_all = 4
	if is_unlocked:
		sb.shadow_color = Color(0, 0, 0, 1)
		sb.shadow_size = 0
		sb.shadow_offset = Vector2(6, 6)
	
	panel.add_theme_stylebox_override("panel", sb)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	margin.add_child(hbox)
	
	# Procedural Icon Node
	var icon_container = Control.new()
	icon_container.custom_minimum_size = Vector2(60, 60)
	icon_container.script = load("res://scripts/procedural_icon.gd")
	icon_container.set_meta("category", category)
	icon_container.set_meta("unlocked", is_unlocked)
	hbox.add_child(icon_container)
	
	var label_vbox = VBoxContainer.new()
	label_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	hbox.add_child(label_vbox)
	
	var title_label = Label.new()
	title_label.text = title.to_upper()
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	title_label.add_theme_constant_override("outline_size", 4 if is_unlocked else 0)
	label_vbox.add_child(title_label)
	
	var desc_label = Label.new()
	desc_label.text = desc
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", Color(0, 0, 0, 0.7))
	label_vbox.add_child(desc_label)
	
	list.add_child(panel)

func refresh_list():
	for child in list.get_children():
		child.queue_free()
	
	var all_achievements = AchievementManager.achievements
	var unlocked = AchievementManager.unlocked_achievements
	
	progress_label.text = str(unlocked.size()) + "/60 UNLOCKED"
	progress_label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	
	for id in all_achievements.keys():
		var data = all_achievements[id]
		var is_unlocked = id in unlocked
		_add_item(data.title, data.desc, is_unlocked, data.get("category", "skill"))
