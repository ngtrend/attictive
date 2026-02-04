extends Control

@onready var score_label: Label = $MarginContainer3/ScoreLabel
@export var name_scene : PackedScene

func _ready() -> void:
	PlayFab.login_completed.connect(_on_login_completed)
func _on_login_completed(has_display_name : bool):
	if !has_display_name:
		add_child(name_scene.instantiate())
func _process(_delta: float) -> void:
	score_label.text = "Score: " + str(Gamedata.score)
