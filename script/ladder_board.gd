extends VBoxContainer
@export var player_highlight : Color = Color.YELLOW
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
		if entry["id"] == PlayFab.playfab_id:
			label.add_theme_color_override("font_color", player_highlight)
		else:
			label.add_theme_font_size_override("font_size",60)
		add_child(label)
