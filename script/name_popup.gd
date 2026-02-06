extends Control

signal submitted(player_name: String)

@onready var user_name: LineEdit = $CenterContainer/Panel/VBoxContainer/UserName
@onready var submit_button: Button = $CenterContainer/Panel/VBoxContainer/SubmitButton

func _ready() -> void:
	submit_button.pressed.connect(_on_submit)
	user_name.text = PlayFab.display_name
func _on_submit():
	var player_name = user_name.text.strip_edges()
	if player_name != "":
		PlayFab.set_display_name(player_name)
		submitted.emit(player_name)
		close()
	else:
		print("Name is empty")
func close():
	var t = create_tween()
	t.tween_property($CenterContainer, "scale", Vector2.ZERO, 0.2)
	await t.finished
	queue_free()


func _on_color_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()
