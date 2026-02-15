extends Control

@onready var score_label: Label = $MarginContainer3/VBoxContainer/ScoreLabel
@onready var bubble: Node2D = $Bubble
const MUSIC := preload("res://assert/music/8-bit-loop-2.mp3")
func _ready() -> void:
	PlayFab.login_completed.connect(_on_login_completed)
	AudioFade.play_music(MUSIC)
	bubble.visible = false
	await get_tree().process_frame
	start_game()
func start_game():
	GameData.reset_game()
	bubble.global_position = GameData.first_circle_position
	bubble.visible = true
func _on_login_completed(has_display_name : bool):
	if !has_display_name:
		GameData.show_name_popup()
func _process(_delta: float) -> void:
	score_label.text = "Score: " + str(GameData.score)
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		GameData.switch_scene("res://scene/main.tscn")
