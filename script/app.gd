extends Node

@onready var ui_layer: Node = $UILayer

func _ready() -> void:
	GameData.switch_scene("res://scene/main.tscn")
	GameData.game_over.connect(_on_game_over)
func _on_game_over():
	var game_ocver = load("res://scene/game_over.tscn").instantiate()
	ui_layer.add_child(game_ocver)
