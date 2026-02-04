extends CanvasLayer

@onready var fade_rect: ColorRect = $FadeRect
var tween: Tween

func fade_out(duration := 0.3):
	if tween:
		tween.kill()

	fade_rect.visible = true
	tween = create_tween()
	tween.tween_property(
		fade_rect,
		"color:a",
		1.0,
		duration
	)
	await tween.finished

func fade_in(duration := 0.3):
	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_property(
		fade_rect,
		"color:a",
		0.0,
		duration
	)
	await tween.finished
	fade_rect.visible = false
