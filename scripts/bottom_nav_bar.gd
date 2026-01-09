extends Control

signal tab_selected(index)

@onready var tabs = $Tabs.get_children()
@onready var indicator = $SelectionIndicator

var active_color = Color("#ffffff") # White text on Emerald bubble
var inactive_color = Color("#7f8c8d") # Grey text on White background
var current_index = 2

func _ready():
	for i in range(tabs.size()):
		tabs[i].pressed.connect(_on_tab_pressed.bind(i))
	
	# Initial position
	call_deferred("_update_visuals", true)

func _on_tab_pressed(index):
	if index == current_index: return
	current_index = index
	emit_signal("tab_selected", index)
	_update_visuals()

func _update_visuals(immediate = false):
	var target_tab = tabs[current_index]
	var target_x = target_tab.global_position.x - global_position.x + (target_tab.size.x - indicator.size.x) / 2.0
	
	if immediate:
		indicator.position.x = target_x
	else:
		var tween = create_tween().set_parallel(true)
		tween.tween_property(indicator, "position:x", target_x, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Update colors
	for i in range(tabs.size()):
		var label = tabs[i].get_node("VBoxContainer/Label")
		var icon = tabs[i].get_node("VBoxContainer/Icon")
		
		var t = create_tween().set_parallel(true)
		if i == current_index:
			t.tween_property(label, "theme_override_colors/font_color", active_color, 0.2)
			t.tween_property(icon, "modulate", active_color, 0.2)
			t.tween_property(tabs[i], "scale", Vector2(1.1, 1.1), 0.2)
		else:
			t.tween_property(label, "theme_override_colors/font_color", inactive_color, 0.2)
			t.tween_property(icon, "modulate", inactive_color, 0.2)
			t.tween_property(tabs[i], "scale", Vector2(1.0, 1.0), 0.2)
