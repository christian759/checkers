extends Control

@onready var list = %List
@onready var progress_label = %ProgressLabel

func _ready():
	AchievementManager.add_visited_menu("achievement")
	refresh_list()

func _add_item(title: String, desc: String, is_unlocked: bool, category: String):
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 110)
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color.WHITE
	sb.set_corner_radius_all(32)
	panel.add_theme_stylebox_override("panel", sb)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 24)
	margin.add_child(hbox)
	
	# Icon Node
	var icon_container = Control.new()
	icon_container.custom_minimum_size = Vector2(64, 64)
	icon_container.script = load("res://scripts/procedural_icon.gd")
	icon_container.set_meta("category", category)
	icon_container.set_meta("accent_color", Color("#1B4332") if is_unlocked else Color("#1B4332", 0.15))
	hbox.add_child(icon_container)
	
	var label_vbox = VBoxContainer.new()
	label_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	label_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(label_vbox)
	
	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", Color("#1B4332") if is_unlocked else Color("#1B4332", 0.3))
	label_vbox.add_child(title_label)
	
	var desc_label = Label.new()
	desc_label.text = desc
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", Color("#1B4332", 0.6) if is_unlocked else Color("#1B4332", 0.2))
	label_vbox.add_child(desc_label)
	
	list.add_child(panel)

func refresh_list():
	for child in list.get_children():
		child.queue_free()
	
	var all_achievements = AchievementManager.achievements
	var unlocked = AchievementManager.unlocked_achievements
	
	if progress_label:
		progress_label.text = str(unlocked.size()) + " of 60 Unlocked"
	
	for id in all_achievements.keys():
		var data = all_achievements[id]
		var is_unlocked = id in unlocked
		_add_item(data.title, data.desc, is_unlocked, data.get("category", "skill"))
