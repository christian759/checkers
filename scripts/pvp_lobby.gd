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
	if play_btn:
		play_btn.pressed.connect(_on_play_pressed)

func _setup_time_controls():
	if not time_grid: return
	
	for child in time_grid.get_children():
		child.queue_free()
		
	for i in range(time_controls.size()):
		var data = time_controls[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 60)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.text = data.name
		btn.flat = true
		
		if i == selected_time_index:
			btn.modulate = Color(0.5, 0.8, 0.4, 1.0) # Green tint for selected
		else:
			btn.modulate = Color(0.7, 0.7, 0.7, 1.0)
		
		btn.pressed.connect(func(): _select_time_control(i))
		time_grid.add_child(btn)

func _select_time_control(index):
	selected_time_index = index
	_setup_time_controls()

func _on_play_pressed():
	GameManager.start_custom_game(GameManager.Mode.PV_AI, 100, 0, GameManager.Side.PLAYER)
