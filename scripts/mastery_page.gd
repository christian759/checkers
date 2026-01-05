extends Control

@onready var card_container = $VBoxContainer/ScrollContainer/HBoxContainer
@onready var global_progress = $VBoxContainer/Header/ProgressLabel

var card_scene = preload("res://scenes/mastery_card.tscn")

var ranks = [
	{"name": "NOVICE", "color": Color("#9e9e9e")}, # Gray
	{"name": "APPRENTICE", "color": Color("#8bc34a")}, # Green
	{"name": "WARRIOR", "color": Color("#03a9f4")}, # Light Blue
	{"name": "KNIGHT", "color": Color("#3f51b5")}, # Indigo
	{"name": "MASTER", "color": Color("#9c27b0")}, # Purple
	{"name": "GRANDMASTER", "color": Color("#f44336")}, # Red
	{"name": "EPIC", "color": Color("#ff9800")}, # Orange
	{"name": "LEGENDARY", "color": Color("#ffeb3b")}, # Yellow/Gold
	{"name": "MYTHIC", "color": Color("#00bcd4")}, # Cyan
	{"name": "DIVINE", "color": Color("#ffffff")} # White/Glow
]

func _ready():
	# For now, let's assume level 1 is the progress
	var current_level = GameManager.current_level if "current_level" in GameManager else 1
	global_progress.text = "Overall Level: " + str(current_level)
	
	populate_cards(current_level)

func populate_cards(current_level: int):
	for i in range(ranks.size()):
		var rank = ranks[i]
		var card = card_scene.instantiate()
		card_container.add_child(card)
		card.setup(rank.name, (i * 20) + 1, rank.color, current_level)
