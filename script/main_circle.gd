extends Control

func _ready() -> void:
	queue_redraw()
func _draw() -> void:
	var pos = size / 2
	pos.y -= 150
	draw_circle(pos , GameData.circle_raduis, Color.WHITE)
	GameData.first_circle_position = global_position + pos
