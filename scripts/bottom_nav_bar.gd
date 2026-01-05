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
	for i in range(tabs.size()):
		tabs[i].btn.pressed.connect(_on_tab_pressed.bind(i))
	
	# Initial Setup
	set_active_tab(2)

func _on_tab_pressed(index: int):
	set_active_tab(index)
	tab_selected.emit(index)

func set_active_tab(index: int):
	var active_color = Color("#1B4332") # Bold Forest Green
	var inactive_color = Color("#1B4332", 0.4)
	
	for i in range(tabs.size()):
		var tab = tabs[i]
		var is_active = (i == index)
		
		var target_color = active_color if is_active else inactive_color
		var tween = create_tween().set_parallel(true)
		
		if tab.icon:
			tween.tween_property(tab.icon, "modulate", target_color, 0.3).set_trans(Tween.TRANS_SINE)
			tween.tween_property(tab.icon, "scale", Vector2(1.1, 1.1) if is_active else Vector2(1.0, 1.0), 0.3)
		
		if tab.label:
			tween.tween_property(tab.label, "theme_override_colors/font_color", target_color, 0.3)
			tab.label.modulate.a = 1.0 if is_active else 0.7
	
	# Animate Indicator
	if indicator:
		var target_tab = tabs[index].btn
		var target_x = target_tab.position.x
		var target_w = target_tab.size.x
		
		var i_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		i_tween.tween_property(indicator, "position:x", target_x, 0.4)
		i_tween.tween_property(indicator, "size:x", target_w, 0.4)
