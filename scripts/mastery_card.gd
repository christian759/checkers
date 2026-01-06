extends Control

@onready var title_label = $Margin/VBox/Title
@onready var grid = $Margin/VBox/GridContainer
@onready var progress_bar = $Margin/VBox/Footer/ProgressBar

var level_icon_scene = preload("res://scenes/mastery_level_icon.tscn")

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pivot_offset = size / 2

func setup(rank_name: String, start_level: int, accent_color: Color, current_global_level: int):
	title_label.text = rank_name
	title_label.add_theme_color_override("font_color", accent_color)

	var completed_count = 0
	for i in range(20):
		var level_num = start_level + i
		var icon = level_icon_scene.instantiate()
		grid.add_child(icon)
		
		var state = 0 # LOCKED
		if level_num < GameManager.max_unlocked_level:
			state = 2 # COMPLETED
			completed_count += 1
		elif level_num == GameManager.max_unlocked_level:
			state = 1 # CURRENT
			
		icon.setup(level_num, state, accent_color)
	
	# Update Progress Bar (Slimmer)
	progress_bar.value = (float(completed_count) / 20.0) * 100.0
	var pb_sb = StyleBoxFlat.new()
	pb_sb.bg_color = accent_color.lerp(GameManager.FOREST, 0.4)
	pb_sb.set_corner_radius_all(100)
	progress_bar.add_theme_stylebox_override("fill", pb_sb)
	progress_bar.custom_minimum_size.y = 8
	
	# Add PLAY Button (fills bottom)
	var footer_btn = progress_bar.get_parent().get_node_or_null("PlayBtn")
	if not footer_btn:
		footer_btn = Button.new()
		footer_btn.name = "PlayBtn"
		progress_bar.get_parent().add_child(footer_btn)
		progress_bar.get_parent().move_child(footer_btn, 0)
	
	footer_btn.custom_minimum_size = Vector2(0, 48)
	var btn_sb = StyleBoxFlat.new()
	btn_sb.bg_color = accent_color
	btn_sb.set_corner_radius_all(24)
	footer_btn.add_theme_stylebox_override("normal", btn_sb)
	footer_btn.add_theme_stylebox_override("hover", btn_sb)
	footer_btn.add_theme_stylebox_override("pressed", btn_sb)
	
	var is_current_rank = (current_global_level >= start_level and current_global_level < start_level + 20)
	footer_btn.text = "CONTINUE" if is_current_rank else "REPLAY"
	footer_btn.add_theme_color_override("font_color", Color.WHITE)
	footer_btn.visible = true
	
	# Cleanup old label if exists
	var old_lbl = progress_bar.get_parent().get_node_or_null("FooterLabel")
	if old_lbl: old_lbl.queue_free()

func _on_mouse_entered():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.04, 1.04), 0.4).set_trans(Tween.TRANS_SINE)
	modulate.a = 1.0

func _on_mouse_exited():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_SINE)
	modulate.a = 1.0
