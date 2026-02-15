extends Node2D

signal popped_signal(circle_type: String)

@export var circle_color := Color.WHITE
@export var play_area : NodePath
@export var effects_node : NodePath
@export var ripple_scene : PackedScene
@export var red_spawn_threshold := 10

const CIRCLE_COLORS = {
	"white" : Color.WHITE,
	"red" : Color.RED
}
const COLOR_POOL = ["white", "white","white","white", "red"]
var popped := false

var radius := GameData.circle_raduis
var circle_type := "white"
var first_circle := true

func _draw() -> void:
	if popped or !get_parent().visible: 
		return
	draw_circle(Vector2.ZERO, radius, circle_color)

func _ready() -> void:
	randomize()
	assign_random_color()
	GameData.register_circle(self)
	await get_tree().create_timer(0.1).timeout
	if first_circle:
		global_position = GameData.first_circle_position
		first_circle = false
	else:
		global_position = get_random_position()
	queue_redraw()

func assign_random_color() -> void:
	var selected_circle_type = COLOR_POOL[randi() % COLOR_POOL.size()]
	circle_type = selected_circle_type if GameData.score > red_spawn_threshold else "white"
	circle_color = CIRCLE_COLORS[circle_type]
func _unhandled_input(event: InputEvent) -> void:
	if popped:
		return
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_mouse_inside():
				pop()
			elif is_player_inside_play_area(event.position) and circle_type == "red":
				pop(true)
	elif event is InputEventScreenTouch:
		if event.pressed:
			if is_touch_inside(event.position):
				pop()
			elif is_player_inside_play_area(event.position) and circle_type == "red":
				pop(true)
func is_touch_inside(pos : Vector2) -> bool:
	var local_pos = to_local(pos)
	return local_pos.length() <= radius
func is_mouse_inside() -> bool:
	return get_local_mouse_position().length() <= radius
func get_play_area_size() -> Rect2:
	var play_area_rect = get_node(play_area) as ColorRect
	return play_area_rect.get_global_rect()
func is_player_inside_play_area(pos : Vector2):
	var rect := get_play_area_size()
	return rect.has_point(pos)
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
func pop(off_red : bool = false):      
	if popped:
		return
	popped = true
	if !off_red:
		emit_signal("popped_signal",circle_type)
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
