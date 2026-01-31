extends Node
var score := 0
func register_circle(circle):
	circle.popped_signal.connect(on_circle_popped)
func on_circle_popped(circle_type: String, is_manual : bool):
	if is_manual:
		if circle_type == "red":
			score -= 1
		elif  circle_type == "white":
			score += 1
	#penality for missing white circles
	else:
		if circle_type == "white":
			score -= 1
	if score <= 0: score = 0
	print(score)
	PlayFab.submit_score(score)
