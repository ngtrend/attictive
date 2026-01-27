extends Node2D

@export var ripple_width: float = 3.0
@export var despawn_time : float = 2.0

var radius: float = 0.0
var color: Color = Color.WHITE
var alpha := 1.0

var fade_speed : float

func _ready():
	fade_speed = 1.0 / despawn_time
	queue_redraw()
func _process(delta: float) -> void:
	alpha -= fade_speed * delta
	if alpha <= 0.0:
		queue_free()
	else:
		queue_redraw()
func _draw():
	var c = color
	c.a = alpha
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, c, ripple_width, true)
