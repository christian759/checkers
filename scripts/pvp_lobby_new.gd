extends Control

@onready var time_grid = %TimeGrid
@onready var play_btn = %PlayBtn

var time_controls = [
	{"name": "10 min", "value": 10},
	{"name": "5 min", "value": 5},
	{"name": "3 min", "value": 3},
	{"name": "1 min", "value": 1}
]

var selected_time_index = 0

func _ready():
	_setup_time_controls()
	# Defensive check for node existence
	if play_btn:
		play_btn.pressed.connect(_on_play_pressed)

func _setup_time_controls():
	if not time_grid: return
	
	# Clear existing
	for child in time_grid.get_children():
		child.queue_free()
		
	for i in range(time_controls.size()):
		var data = time_controls[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 60)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.text = data.name
		
		# Custom styling
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color("3e4042") # Dark Grey
		sb.corner_radius_all = 8
		sb.border_width_all = 0
		
		# Selected State Highlights
		if i == selected_time_index:
			sb.bg_color = Color("4b4d4f")
			sb.border_width_all = 2
			sb.border_color = Color("7fa650") # Green highlight
			
		btn.add_theme_stylebox_override("normal", sb)
		btn.add_theme_stylebox_override("hover", sb)
		btn.add_theme_stylebox_override("pressed", sb)
		
		btn.pressed.connect(func(): _select_time_control(i))
		time_grid.add_child(btn)

func _select_time_control(index):
	selected_time_index = index
	_setup_time_controls() # Re-render to update highlights (simple approach)

func _on_play_pressed():
	# For now, just start a Standard AI game as "Quick Play"
	# In future, this would pass the time control
	GameManager.start_custom_game(GameManager.Mode.PV_AI, 100, 0, GameManager.Side.PLAYER)
