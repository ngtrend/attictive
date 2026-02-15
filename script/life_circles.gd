extends Control

@export var radius := 8.0
@export var spacing := 10.0
@export var color := Color.RED
@export var life_texture : Texture
var max_lives

func _ready():
	GameData.life_changed.connect(queue_redraw)
	max_lives = GameData.LIFES
	var size = life_texture.get_size()
	custom_minimum_size.x = max_lives * (size.x + spacing)
	custom_minimum_size.y = size.y
func _draw():
	var halves_left := GameData.life_halves
	var size = life_texture.get_size()
	var y = size.y / 2

	for i in range(max_lives):
		var x = i * (size.x + spacing)

		var pos := Vector2(x, 0)

		if halves_left >= 2:
			# FULL circle
			draw_texture(life_texture, pos)
			halves_left -= 2

		elif halves_left == 1:
			# HALF circle (LEFT half)
			draw_texture_rect_region(
				life_texture,
				Rect2(pos, Vector2(size.x / 2, size.y)),
				Rect2(Vector2.ZERO, Vector2(size.x / 2, size.y))
			)
			halves_left -= 1
