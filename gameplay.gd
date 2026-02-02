extends Node

var score := 0
var first_circle_position := Vector2.ZERO
var circle_raduis := 100.0

func register_circle(circle):
	circle.popped_signal.connect(on_circle_popped)
func on_circle_popped(circle_type: String):
	if circle_type == "red":
		score -= 5
	elif  circle_type == "white":
		score += 1
	if score <= 0: score = 0
	print(score)
	PlayFab.submit_score(score)
