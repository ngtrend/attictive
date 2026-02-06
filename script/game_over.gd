extends Control
@onready var restart: Button = $CenterContainer/VBoxContainer/HBoxContainer/Restart
@onready var exit: Button = $CenterContainer/VBoxContainer/HBoxContainer/Exit

func _ready() -> void:
	restart.pressed.connect(_on_restart_pressed)
	exit.pressed.connect(_on_exit_pressed)
	Gamedata.reset_game()
func _on_restart_pressed():
	Gamedata.switch_scene("res://scene/game_play.tscn")
	close()
func _on_exit_pressed():
	Gamedata.switch_scene("res://scene/main.tscn")
	close()
func close():
	var t = create_tween()
	t.tween_property($CenterContainer, "scale", Vector2.ZERO, 0.2)
	await t.finished
	queue_free()


func _on_color_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("Clicked")
