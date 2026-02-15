extends Control

signal submitted(player_name: String)

@onready var user_name: LineEdit = $CenterContainer/Panel/VBoxContainer/UserName
@onready var submit_button: Button = $CenterContainer/Panel/VBoxContainer/SubmitButton
@onready var error_label: Label = $CenterContainer/Panel/VBoxContainer/ErrorLabel

func _ready() -> void:
	submit_button.pressed.connect(_on_submit)
	user_name.text = PlayFab.display_name
	error_label.hide()
func _on_submit():
	var player_name = user_name.text.strip_edges()
	print(player_name)
	if player_name == "":
		show_error_msg("Empty")
	elif player_name.length() < 3:
		show_error_msg("Small")
	elif player_name.length() > 10:
		show_error_msg("Big")
	else:
		PlayFab.set_display_name(player_name)
		submitted.emit(player_name)
		close()
func close():
	var t = create_tween()
	t.tween_property($CenterContainer, "scale", Vector2.ZERO, 0.2)
	await t.finished
	queue_free()


func _on_color_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		close()
func show_error_msg(msg : String):
	error_label.show()
	error_label.text = msg
	await get_tree().create_timer(2).timeout
	error_label.hide()
