extends Node2D
@onready var arrow: CharacterBody2D = $arrow

var is_dragging : bool = false
var start_pos : Vector2 
func _process(delta: float) -> void:
	if is_dragging:
		var drag = start_pos - get_global_mouse_position()
		var angle = drag.angle() - deg_to_rad(90)
		var max_angle = deg_to_rad(60)
		angle = clamp(angle, -max_angle, max_angle)
		arrow.rotation = angle
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				start_pos = get_global_mouse_position()
				print("mouse pressed")
#detecting mouse release globally
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if is_dragging:
				is_dragging = false
				fire_arrow()
				print("mouse released")
func fire_arrow():
	var drag_vector = start_pos - get_global_mouse_position()
	var power = drag_vector.length() * 5
	arrow.velocity = -arrow.transform.y * power
func _physics_process(delta: float) -> void:
	arrow.move_and_slide()
