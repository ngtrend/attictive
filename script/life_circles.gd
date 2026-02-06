extends Control

@export var radius := 8.0
@export var spacing := 10.0
@export var color := Color.RED

func _ready():
	Gamedata.life_changed.connect(queue_redraw)

func _draw():
	var lives = Gamedata.lifes
	var y := size.y / 2

	for i in range(lives):
		var x := radius + i * (radius * 2 + spacing)
		draw_circle(Vector2(x, y), radius, color)
