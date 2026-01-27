extends Node

var score := 0
func register_circle(circle):
	circle.popped_signal.connect(on_circle_popped)
func on_circle_popped():
	score += 1
	print(score)
	PlayFab.submit_score(score)
