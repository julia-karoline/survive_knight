class_name GameOverUI
extends CanvasLayer

@onready var time_label: Label = %TimeLabel
@onready var monsters_label: Label = %MonstersLabel
@onready var countdown_label: Label = %CountdownClock


@export var restart_delay = 5.0
var restart_cooldown: float
var restart_cooldown_string: String

func _ready():
	time_label.text = GameManager.time_elapsed_string
	monsters_label.text = str(GameManager.monsters_defeated_counter)
	restart_cooldown = restart_delay

func _process(delta):
	restart_cooldown -= delta
	var restart_cooldown_in_seconds: int = floori(restart_cooldown)
	var seconds: int = restart_cooldown_in_seconds % 60
	var minutes: int = restart_cooldown_in_seconds / 60
	restart_cooldown_string = "%02d:%02d" % [minutes, seconds]
	countdown_label.text = str(restart_cooldown_string)
	if restart_cooldown <= 0.0:
		restart_game()

func restart_game():
	GameManager.reset()
	get_tree().reload_current_scene()

