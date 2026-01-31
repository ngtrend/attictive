extends VBoxContainer

func _ready() -> void:
	PlayFab.leaderboard_updated.connect(_on_leaderboard_updated)
func _on_leaderboard_updated():
	render_leaderboard(PlayFab.leaderboard_data)
	print(PlayFab.leaderboard_data)
func render_leaderboard(data: Array):
	for child in get_children():
		child.queue_free()

	for entry in data:
		var label := Label.new()
		label.text = "%d. %s : %d" % [entry["rank"], entry["name"], entry["score"]]
		add_child(label)
