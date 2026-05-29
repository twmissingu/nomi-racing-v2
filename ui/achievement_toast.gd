extends CanvasLayer

## Achievement unlock toast notification.

const BG_COLOR := Color("1E2740")
const ACCENT := Color("FF6B1A")
const TEXT_PRIMARY := Color("F0F0F0")
const GOLD := Color("FFD700")

var _queue: Array = []
var _showing: bool = false

func _ready() -> void:
	layer = 50
	AchievementManager.achievement_unlocked.connect(_on_achievement_unlocked)

func _on_achievement_unlocked(_id: String, achievement_name: String) -> void:
	_queue.append(achievement_name)
	if not _showing:
		_show_next()

func _show_next() -> void:
	if _queue.is_empty():
		_showing = false
		return
	_showing = true
	var achievement_name: String = _queue.pop_front()

	var container := HBoxContainer.new()
	container.position = Vector2(1920, 40)
	container.add_theme_constant_override("separation", 12)
	add_child(container)

	var icon_label := Label.new()
	icon_label.text = "🏆"
	icon_label.add_theme_font_size_override("font_size", 32)
	container.add_child(icon_label)

	var text_vbox := VBoxContainer.new()
	container.add_child(text_vbox)

	var title_label := Label.new()
	title_label.text = "ACHIEVEMENT UNLOCKED"
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.add_theme_color_override("font_color", ACCENT)
	text_vbox.add_child(title_label)

	var name_label := Label.new()
	name_label.text = achievement_name
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.add_theme_color_override("font_color", GOLD)
	text_vbox.add_child(name_label)

	# Background panel
	var bg := ColorRect.new()
	bg.color = Color(BG_COLOR, 0.9)
	bg.position = Vector2(-16, -8)
	bg.size = Vector2(360, 70)
	container.add_child(bg)
	container.move_child(bg, 0)

	# Slide in from right
	var tween := create_tween()
	tween.tween_property(container, "position:x", 1560.0, 0.4) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_interval(2.5)
	tween.tween_property(container, "position:x", 1920.0, 0.3) \
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(func():
		container.queue_free()
		_show_next()
	)
