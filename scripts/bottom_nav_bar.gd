extends Control

signal tab_selected(index)

var active_color = Color("#ffffff") # Pure White
var inactive_color = Color("#cfe0cf") # Soft Mint Gray

@onready var tabs_container = $Tabs
@onready var indicator = $SelectionIndicator

@onready var tabs = [
	{"btn": $Tabs/Daily, "icon": $Tabs/Daily/VBoxContainer/Icon, "label": $Tabs/Daily/VBoxContainer/Label, "id": "daily"},
	{"btn": $Tabs/PvP, "icon": $Tabs/PvP/VBoxContainer/Icon, "label": $Tabs/PvP/VBoxContainer/Label, "id": "pvp"},
	{"btn": $Tabs/Mastery, "icon": $Tabs/Mastery/VBoxContainer/Icon, "label": $Tabs/Mastery/VBoxContainer/Label, "id": "mastery"},
	{"btn": $Tabs/Achievement, "icon": $Tabs/Achievement/VBoxContainer/Icon, "label": $Tabs/Achievement/VBoxContainer/Label, "id": "achievement"},
	{"btn": $Tabs/Settings, "icon": $Tabs/Settings/VBoxContainer/Icon, "label": $Tabs/Settings/VBoxContainer/Label, "id": "settings"}
]

func _ready():
	for i in range(tabs.size()):
		var tab = tabs[i]
		tab.btn.pressed.connect(_on_tab_pressed.bind(i))
	
	# Initial position fix
	await get_tree().process_frame
	select_tab(2) # Mastery by default

func _on_tab_pressed(index):
	select_tab(index)
	emit_signal("tab_selected", index)

func select_tab(index):
	for i in range(tabs.size()):
		var tab = tabs[i]
		if i == index:
			tab.icon.modulate = active_color
			tab.label.add_theme_color_override("font_color", active_color)
			
			# Animate Indicator
			if indicator:
				var target_pos_x = tab.btn.global_position.x + (tab.btn.size.x / 2.0) - (indicator.size.x / 2.0)
				
				var tween = create_tween().set_parallel(true)
				tween.tween_property(indicator, "global_position:x", target_pos_x, 0.4).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
			
			# Button Scale Pulse
			if tab.btn:
				var scale_tween = create_tween()
				scale_tween.tween_property(tab.btn, "scale", Vector2(1.05, 1.05), 0.1).set_trans(Tween.TRANS_SINE)
				scale_tween.tween_property(tab.btn, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE)
		else:
			tab.icon.modulate = inactive_color
			tab.label.add_theme_color_override("font_color", inactive_color)
			tab.btn.scale = Vector2(1.0, 1.0)
