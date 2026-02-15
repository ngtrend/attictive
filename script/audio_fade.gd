extends AudioStreamPlayer

@onready var music: AudioStreamPlayer = $"."

var fade_time := 0.8
var music_volume := -10
var muted := false

func play_music(stream: AudioStream, fade := true):
	if music.stream == stream and music.playing:
		return
	if muted:
		return
	if fade and music.playing:
		await fade_out()

	music.stream = stream
	music.volume_db = -40
	music.play()
	music.stream.loop = true
	if fade:
		fade_in()

func fade_in():
	var tween = create_tween()
	tween.tween_property(music, "volume_db", music_volume, fade_time)

func fade_out():
	var tween = create_tween()
	tween.tween_property(music, "volume_db", -40, fade_time)
	await tween.finished

func mute_music(fade := true):
	muted = true
	if fade and playing:
		await fade_out()
	stop()
func unmute_music():
	muted = false
	if stream:
		volume_db = -40
		play()
		fade_in()
func toggle_music():
	if muted:
		unmute_music()
	else:
		mute_music()
