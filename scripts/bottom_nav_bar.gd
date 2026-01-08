extends Control

signal tab_selected(index: int)

@onready var indicator = %SelectionIndicator

@onready var tabs = [
	{"btn": $Margin/DockHull/Tabs/Daily, "icon": $Margin/DockHull/Tabs/Daily/VBox/Icon, "label": $Margin/DockHull/Tabs/Daily/VBox/Label},
	{"btn": $Margin/DockHull/Tabs/PvP, "icon": $Margin/DockHull/Tabs/PvP/VBox/Icon, "label": $Margin/DockHull/Tabs/PvP/VBox/Label},
	{"btn": $Margin/DockHull/Tabs/Mastery, "icon": $Margin/DockHull/Tabs/Mastery/VBox/Icon, "label": $Margin/DockHull/Tabs/Mastery/VBox/Label},
	{"btn": $Margin/DockHull/Tabs/Achievement, "icon": $Margin/DockHull/Tabs/Achievement/VBox/Icon, "label": $Margin/DockHull/Tabs/Achievement/VBox/Label},
	{"btn": $Margin/DockHull/Tabs/Settings, "icon": $Margin/DockHull/Tabs/Settings/VBox/Icon, "label": $Margin/DockHull/Tabs/Settings/VBox/Label}
]

func _ready():
	# v7 Glass Dock
	var dock_panel = $Margin/DockHull
	if dock_panel:
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color.WHITE
		sb.set_corner_radius_all(0) # Flat bottom edge
		# No shadow or border for grounded look
		dock_panel.add_theme_stylebox_override("panel", sb)

	# Indicator: Minimalist Dot
	if indicator:
		var i_sb = StyleBoxFlat.new()
		i_sb.bg_color = GameManager.FOREST
		i_sb.set_corner_radius_all(100) # Circle
		indicator.add_theme_stylebox_override("panel", i_sb)

	for i in range(tabs.size()):
		tabs[i].btn.pressed.connect(_on_tab_pressed.bind(i))
	
	# Initial Setup
	set_active_tab(2)

func _on_tab_pressed(index: int):
	set_active_tab(index)
	tab_selected.emit(index)

func set_active_tab(index: int):
	var active_color = GameManager.FOREST
	var inactive_color = GameManager.FOREST.lerp(Color.WHITE, 0.6)
	
	for i in range(tabs.size()):
		var tab = tabs[i]
		var is_active = (i == index)
		
		var target_color = active_color if is_active else inactive_color
		var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		
		if tab.icon:
			tween.tween_property(tab.icon, "modulate", target_color, 0.4)
			# Subtle scale up for active
			tween.tween_property(tab.icon, "scale", Vector2(1.2, 1.2) if is_active else Vector2(1.0, 1.0), 0.5)
			# No offset animation
			pass
		
		# Labels are hidden in this minimalist design, or very subtle
		if tab.label:
			tab.label.visible = false
	
	# Indicator removed - no dot animation
	# if indicator:
	# 	indicator.visible = false
