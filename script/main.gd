extends Control

@onready var play_button: Button = $MenuUi/VBoxContainer/PlayButton
@onready var menu_ui: CenterContainer = $MenuUi
@onready var settings_button: TextureButton = $MarginContainer/VBoxContainer/SettingsButton
@onready var settings_panel: Panel = $MarginContainer/VBoxContainer/SettingsPanel
@onready var music_button: Button = $MarginContainer/VBoxContainer/SettingsPanel/Controls/MusicButton
@onready var sfx_button: Button = $MarginContainer/VBoxContainer/SettingsPanel/Controls/SfxButton
@onready var edit_button: Button = $MarginContainer/VBoxContainer/SettingsPanel/Controls/EditButton
@onready var background_music: AudioStreamPlayer = $BackgroundMusic

var settings_tween: Tween
const SLIDE_OFFSET := 20

func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	music_button.pressed.connect(_on_music_toggle)
	sfx_button.pressed.connect(_on_sfx_toggle)
	edit_button.pressed.connect(_on_edit_button_toggle)
	settings_panel.hide()
	await get_tree().process_frame
func _on_play_button_pressed():
	play_button.disabled = true
	Gamedata.switch_scene("res://scene/game_play.tscn")
func _on_settings_button_pressed():
	if !settings_panel.visible:
		show_settings()
	else:
		hide_settings()
func show_settings():
	if settings_tween and settings_tween.is_valid():
		settings_tween.kill()
	
	settings_panel.visible = true

	var button_pos = settings_button.global_position
	var button_size = settings_button.size

	var shown_y = button_pos.y + button_size.y
	var hidden_y = shown_y - SLIDE_OFFSET

	settings_panel.position = Vector2(button_pos.x - 10, hidden_y)
	settings_panel.modulate.a = 0.0

	settings_tween = create_tween()
	settings_tween.set_parallel(true)

	settings_tween.tween_property(
		settings_panel, "position:y", shown_y, 0.28
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	settings_tween.tween_property(
		settings_panel, "modulate:a", 1.0, 0.25
	).set_ease(Tween.EASE_OUT)

func hide_settings():
	if settings_tween and settings_tween.is_valid():
		settings_tween.kill()

	var button_pos = settings_button.global_position
	var button_size = settings_button.size

	var shown_y = button_pos.y + button_size.y
	var hidden_y = shown_y - SLIDE_OFFSET

	settings_tween = create_tween()
	settings_tween.set_parallel(true)

	settings_tween.tween_property(
		settings_panel, "position:y", hidden_y, 0.22
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

	settings_tween.tween_property(
		settings_panel, "modulate:a", 0.0, 0.2
	).set_ease(Tween.EASE_IN)

	settings_tween.finished.connect(func():
		settings_panel.visible = false
	)
func _on_music_toggle():
	if Gamedata.music_volume > 0:
		Gamedata.music_volume = 0.0
	else:
		Gamedata.music_volume = 0.5
	background_music.volume_db = linear_to_db(Gamedata.music_volume)
	update_music_toggle()
func _on_sfx_toggle():
	if Gamedata.sfx_volume > 0:
		Gamedata.sfx_volume = 0.0
	else:
		Gamedata.sfx_volume = 0.5
	update_sfx_toggle()
func update_music_toggle():
	if Gamedata.music_volume > 0.0:
		music_button.icon = preload("res://assert/icon/music-on.png")
	else:
		music_button.icon = preload("res://assert/icon/music-off.png")
func update_sfx_toggle():
	if Gamedata.sfx_volume > 0:
		sfx_button.icon = preload("res://assert/icon/sfx-on.png")
	else:
		sfx_button.icon = preload("res://assert/icon/sfx-off.png")
func _on_edit_button_toggle():
	Gamedata.show_name_popup()
