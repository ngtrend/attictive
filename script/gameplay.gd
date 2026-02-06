extends Control

@onready var score_label: Label = $MarginContainer3/VBoxContainer/ScoreLabel

func _ready() -> void:
	PlayFab.login_completed.connect(_on_login_completed)
	Gamedata.reset_game()
func _on_login_completed(has_display_name : bool):
	if !has_display_name:
		Gamedata.show_name_popup()
func _process(_delta: float) -> void:
	score_label.text = "Score: " + str(Gamedata.score)
