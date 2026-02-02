extends Control
@onready var play_button: Button = $MenuUi/VBoxContainer/PlayButton
@onready var gameplay: Control = $Gameplay
@onready var menu_ui: CenterContainer = $MenuUi
@onready var settings_button: TextureButton = $MarginContainer/VBoxContainer/SettingsButton
@onready var settings_panel: Panel = $MarginContainer/VBoxContainer/SettingsPanel

var settings_tween: Tween
const SLIDE_OFFSET := 20

func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	await get_tree().process_frame
	settings_panel.hide()
	gameplay.hide()
func _on_play_button_pressed():
	play_button.disabled = true
	menu_ui.hide()
	gameplay.show()
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
