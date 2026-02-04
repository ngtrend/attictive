extends Control

func _ready() -> void:
	queue_redraw()
func _draw() -> void:
	var pos = size / 2
	pos.y -= 150
	draw_circle(pos , Gamedata.circle_raduis, Color.WHITE)
	Gamedata.first_circle_position = global_position + pos
