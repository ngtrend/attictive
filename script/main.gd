extends Control

@onready var play_button: Button = $MenuUi/VBoxContainer/PlayButton
@onready var menu_ui: CenterContainer = $MenuUi
@onready var settings_button: TextureButton = $MarginContainer/VBoxContainer/SettingsButton
@onready var settings_panel: Panel = $MarginContainer/VBoxContainer/SettingsPanel
@onready var music_button: Button = $MarginContainer/VBoxContainer/SettingsPanel/Controls/MusicButton
@onready var sfx_button: Button = $MarginContainer/VBoxContainer/SettingsPanel/Controls/SfxButton
@onready var edit_button: Button = $MarginContainer/VBoxContainer/SettingsPanel/Controls/EditButton


var settings_tween: Tween
const SLIDE_OFFSET := 20
const MENU_MUSIC := preload("res://assert/music/8-bit-loop-1.mp3")
func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	music_button.pressed.connect(_on_music_toggle)
	sfx_button.pressed.connect(_on_sfx_toggle)
	edit_button.pressed.connect(_on_edit_button_toggle)
	settings_panel.hide()
	AudioFade.play_music(MENU_MUSIC)
	await get_tree().process_frame
func _on_play_button_pressed():
	play_button.disabled = true
	GameData.switch_scene("res://scene/game_play.tscn")
	await get_tree().create_timer(0.8).timeout
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
	AudioFade.toggle_music()
	update_music_toggle()
func _on_sfx_toggle():
	GameData.sfx_volume = 0.0 if GameData.sfx_volume > 0.0 else 0.5
	update_sfx_toggle()
func update_music_toggle():
	if !AudioFade.muted:
		music_button.icon = preload("res://assert/icon/music-on.png")
	else:
		music_button.icon = preload("res://assert/icon/music-off.png")
func update_sfx_toggle():
	if GameData.sfx_volume > 0:
		sfx_button.icon = preload("res://assert/icon/sfx-on.png")
	else:
		sfx_button.icon = preload("res://assert/icon/sfx-off.png")
func _on_edit_button_toggle():
	GameData.show_name_popup()
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
