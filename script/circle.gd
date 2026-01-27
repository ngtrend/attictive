extends Node2D

signal popped_signal

@export var radius := 20.0
@export var circle_color := Color.WHITE
@export var play_area : NodePath
@export var effects_node : NodePath
@export var ripple_scene : PackedScene

var popped := false

func _draw() -> void:
	if popped: 
		return
	draw_circle(Vector2.ZERO, radius, circle_color)

func _ready() -> void:
	randomize()
	GamePlay.register_circle(self)
	await get_tree().create_timer(0.0).timeout
	global_position = get_random_position()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if popped:
		return
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_mouse_inside():
				pop()
	elif event is InputEventScreenTouch:
		if event.pressed:
			if is_touch_inside(event.position):
				pop()
func is_touch_inside(pos : Vector2) -> bool:
	var local_pos = to_local(pos)
	return local_pos.length() <= radius
func is_mouse_inside() -> bool:
	return get_local_mouse_position().length() <= radius

func get_play_area_size() -> Rect2:
	var play_area_rect = get_node(play_area) as ColorRect
	return play_area_rect.get_global_rect()

func get_random_position() -> Vector2:
	var rect := get_play_area_size()
	var x = randf_range(rect.position.x + radius , rect.position.x + rect.size.x - radius)
	var y = randf_range(rect.position.y + radius , rect.position.y + rect.size.y - radius)
	return Vector2(x,y)

func respawn():
	popped = false
	global_position = get_random_position()
	queue_redraw()
func pop():      
	if popped:
		return
	popped = true
	emit_signal("popped_signal")
	_spawn_ripple_at_global(global_position)
	await get_tree().create_timer(0.2).timeout
	respawn()

func _spawn_ripple_at_global(pos: Vector2)-> void:
	var ripple = ripple_scene.instantiate()
	ripple.color = circle_color
	ripple.radius = radius
	var effect = get_node_or_null(effects_node)
	if effect:
		effect.add_child(ripple)
		ripple.global_position = pos
