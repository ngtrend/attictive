extends Node2D

signal popped_signal(circle_type: String)

@export var radius := 20.0
@export var circle_color := Color.WHITE
@export var life_span := 3.0
@export var play_area : NodePath
@export var effects_node : NodePath
@export var ripple_scene : PackedScene

const CIRCLE_COLORS = {
	"white" : Color.WHITE,
	"red" : Color.RED
}
const COLOR_POOL = ["white", "white","white","white", "red"]
var popped := false
var circle_type := "white"
var life_timer : Timer

func _draw() -> void:
	if popped: 
		return
	draw_circle(Vector2.ZERO, radius, circle_color)

func _ready() -> void:
	randomize()
	assign_random_color()
	GamePlay.register_circle(self)
	life_timer = Timer.new()
	life_timer.one_shot = true
	life_timer.timeout.connect(_on_life_span_expires)
	add_child(life_timer)
	
	await get_tree().create_timer(0.1).timeout
	global_position = get_random_position()
	queue_redraw()
	
	life_timer.start(life_span)
func _on_life_span_expires():
	if popped:
		return
	pop(false)
func assign_random_color() -> void:
	circle_type = COLOR_POOL[randi() % COLOR_POOL.size()]
	circle_color = CIRCLE_COLORS[circle_type]
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
	assign_random_color()
	global_position = get_random_position()
	queue_redraw()
	life_timer.start(life_span)
func pop(is_manual : bool = true):      
	if popped:
		return
	popped = true
	emit_signal("popped_signal",circle_type, is_manual)
	_spawn_ripple_at_global(global_position)
	await get_tree().create_timer(0.1).timeout
	respawn()

func _spawn_ripple_at_global(pos: Vector2)-> void:
	var ripple = ripple_scene.instantiate()
	ripple.color = circle_color
	ripple.radius = radius
	var effect = get_node_or_null(effects_node)
	if effect:
		effect.add_child(ripple)
		ripple.global_position = pos
