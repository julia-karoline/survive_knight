extends Node

@export var game_ui: CanvasLayer
@export var game_over_ui_template: PackedScene
@export var new_ritual: PackedScene

func _ready():
	GameManager.game_over.connect(trigger_game_over)
	unlock_new_ritual()

func unlock_new_ritual():
	if GameManager.monsters_defeated_counter >= 30:
		var ritual_warning = new_ritual.instantiate()
		add_child(ritual_warning)

func trigger_game_over():
	if game_ui:
		game_ui.queue_free()
		game_ui = null
		
	var game_over_ui: GameOverUI = game_over_ui_template.instantiate()
	add_child(game_over_ui)
		
		
