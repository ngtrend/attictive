extends VBoxContainer

func _ready() -> void:
	PlayFab.leadderboard_updated.connect(ladderboard_data_update)
func ladderboard_data_update():
	render_leadderboard(PlayFab.leaderboard_data)
func render_leadderboard(data: Array):
	for child in get_children():
		child.queue_free()

	for entry in data:
		var label := Label.new()
		
		if entry.id == PlayFab.playfab_id:
			label.text = "%d. you : %d" % [entry.rank, entry.score]
		else:
			label.text = "%d. %s : %d" % [entry.rank, entry.name, entry.score]

		add_child(label)
