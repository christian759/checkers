extends HBoxContainer

signal tab_selected(index)

var active_color = Color("#ffcc00") # Vibrant Yellow
var inactive_color = Color("#ffffff") # Pure White

@onready var tabs = [
	{"btn": $Daily, "icon": $Daily/VBoxContainer/Icon, "label": $Daily/VBoxContainer/Label, "id": "daily"},
	{"btn": $PvP, "icon": $PvP/VBoxContainer/Icon, "label": $PvP/VBoxContainer/Label, "id": "pvp"},
	{"btn": $Mastery, "icon": $Mastery/VBoxContainer/Icon, "label": $Mastery/VBoxContainer/Label, "id": "mastery"},
	{"btn": $Achievement, "icon": $Achievement/VBoxContainer/Icon, "label": $Achievement/VBoxContainer/Label, "id": "achievement"},
	{"btn": $Settings, "icon": $Settings/VBoxContainer/Icon, "label": $Settings/VBoxContainer/Label, "id": "settings"}
]

func _ready():
	for i in range(tabs.size()):
		var tab = tabs[i]
		tab.btn.pressed.connect(_on_tab_pressed.bind(i))
	
	select_tab(1) # PvP/Board by default

func _on_tab_pressed(index):
	select_tab(index)
	emit_signal("tab_selected", index)

func select_tab(index):
	for i in range(tabs.size()):
		var tab = tabs[i]
		if i == index:
			tab.icon.modulate = active_color
			tab.label.add_theme_color_override("font_color", active_color)
			# Small scale animation
			var tween = create_tween()
			tween.tween_property(tab.btn, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_SINE)
		else:
			tab.icon.modulate = inactive_color
			tab.label.add_theme_color_override("font_color", inactive_color)
			tab.btn.scale = Vector2(1.0, 1.0)
