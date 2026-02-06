extends Node

signal game_over ;
signal  life_changed;
const LIFES := 3

var score := 0
var lifes := 3

var first_circle_position := Vector2.ZERO
var circle_raduis := 100.0
var music_volume := 0.5
var sfx_volume := 0.5

var sfx_player : AudioStreamPlayer
var current_scene : Node

func _ready() -> void:
	sfx_player =  AudioStreamPlayer.new()
	add_child(sfx_player)
func register_circle(circle):
	circle.popped_signal.connect(on_circle_popped)
func on_circle_popped(circle_type: String):
	if circle_type == "red":
		score -= 5
		reduce_life()
		sfx_volume = 0.2
		play_sfx("res://assert/music/wrong-explode.mp3")
	elif  circle_type == "white":
		score += 1
		sfx_volume = 0.5
		play_sfx("res://assert/music/one-beep-white.mp3")
	if score <= 0: score = 0
	print(score)
	PlayFab.submit_score(score)

func switch_scene(scene_path: String):
	await get_tree().root.get_node("App/TransitionLayer").fade_out()

	if current_scene:
		current_scene.queue_free()

	var scene = load(scene_path).instantiate()
	get_tree().root.get_node("App/SceneRoot").add_child(scene)
	current_scene = scene

	await get_tree().root.get_node("App/TransitionLayer").fade_in()
func show_name_popup():
	var app = get_tree().root.get_node("App")
	var ui_layer = app.get_node("UILayer")

	var popup = load("res://scene/name_popup.tscn").instantiate()
	ui_layer.add_child(popup)

	popup.submitted.connect(_on_name_submitted)

func _on_name_submitted(player_name: String):
	print("Name set:", player_name)
	# resume game / enable input / etc

func play_sfx(sound_path: String):
	var stream = load(sound_path)
	if stream:
		sfx_player.stream = stream
		sfx_player.volume_db = linear_to_db(Gamedata.sfx_volume)
		sfx_player.play()
func reduce_life():
	lifes -= 1
	emit_signal("life_changed")
	if lifes <= 0:
		emit_signal("game_over")
func reset_game():
	lifes = LIFES
	score = 0
	PlayFab.submit_score_now(score)
	print("Game reset")
