extends Control

@onready var user_name: LineEdit = $CenterContainer/VBoxContainer/UserName
@onready var submit_button: Button = $CenterContainer/VBoxContainer/SubmitButton

func _ready() -> void:
	get_tree().paused = true
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	
	submit_button.pressed.connect(_on_submit)
func _on_submit():
	var player_name = user_name.text.strip_edges()
	if player_name != "":
		PlayFab.set_display_name(player_name)
		get_tree().paused = false
		queue_free()
