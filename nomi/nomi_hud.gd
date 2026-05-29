extends CanvasLayer

## NOMI HUD: corner avatar with expression animation and speech bubble.

var nomi_controller: Node
var avatar_panel: PanelContainer
var eye_left: ColorRect
var eye_right: ColorRect
var mouth: ColorRect
var speech_bubble: PanelContainer
var speech_label: Label
var speech_tween: Tween

# Layout
const AVATAR_SIZE := 80
const AVATAR_MARGIN := 16
const BUBBLE_MAX_WIDTH := 300

# Colors
const BG_DARK := Color("0A0E1A")
const NIO_BLUE := Color("00A1E0")

var current_expression: String = "idle"
var blink_timer: float = 0.0
var blink_interval: float = 3.0

func _ready() -> void:
	layer = 15
	_build_avatar()
	_build_speech_bubble()

func set_controller(controller: Node) -> void:
	nomi_controller = controller
	if nomi_controller:
		nomi_controller.expression_changed.connect(_on_expression_changed)
		nomi_controller.commentary_requested.connect(_on_commentary_requested)

func _build_avatar() -> void:
	# Avatar container (bottom-left corner)
	avatar_panel = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(BG_DARK, 0.8)
	sb.set_corner_radius_all(40)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	avatar_panel.add_theme_stylebox_override("panel", sb)
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	avatar_panel.position = Vector2(AVATAR_MARGIN, viewport_size.y - AVATAR_SIZE - AVATAR_MARGIN)
	avatar_panel.size = Vector2(AVATAR_SIZE, AVATAR_SIZE)
	add_child(avatar_panel)

	# NOMI face container
	var face := Control.new()
	face.size = Vector2(AVATAR_SIZE - 16, AVATAR_SIZE - 16)
	avatar_panel.add_child(face)

	# Background circle (NOMI body)
	var bg_circle := ColorRect.new()
	bg_circle.color = NIO_BLUE
	bg_circle.position = Vector2(4, 4)
	bg_circle.size = Vector2(AVATAR_SIZE - 24, AVATAR_SIZE - 24)
	face.add_child(bg_circle)

	# Left eye
	eye_left = ColorRect.new()
	eye_left.color = Color.WHITE
	eye_left.size = Vector2(12, 16)
	eye_left.position = Vector2(14, 18)
	face.add_child(eye_left)

	# Right eye
	eye_right = ColorRect.new()
	eye_right.color = Color.WHITE
	eye_right.size = Vector2(12, 16)
	eye_right.position = Vector2(38, 18)
	face.add_child(eye_right)

	# Mouth
	mouth = ColorRect.new()
	mouth.color = Color.WHITE
	mouth.size = Vector2(20, 6)
	mouth.position = Vector2(22, 40)
	face.add_child(mouth)

func _build_speech_bubble() -> void:
	speech_bubble = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(BG_DARK, 0.9)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.border_width_top = 2
	sb.border_width_bottom = 2
	sb.border_color = NIO_BLUE
	speech_bubble.add_theme_stylebox_override("panel", sb)
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	speech_bubble.position = Vector2(AVATAR_SIZE + AVATAR_MARGIN + 8, viewport_size.y - AVATAR_SIZE - AVATAR_MARGIN - 10)
	speech_bubble.size = Vector2(BUBBLE_MAX_WIDTH, 60)
	speech_bubble.visible = false
	add_child(speech_bubble)

	speech_label = Label.new()
	speech_label.add_theme_font_size_override("font_size", 16)
	speech_label.add_theme_color_override("font_color", Color.WHITE)
	speech_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	speech_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	speech_label.size = Vector2(BUBBLE_MAX_WIDTH - 32, 40)
	speech_bubble.add_child(speech_label)

func _process(delta: float) -> void:
	# Blink animation
	blink_timer += delta
	if blink_timer >= blink_interval:
		blink_timer = 0.0
		_blink()

func _blink() -> void:
	if not eye_left or not eye_right:
		return
	var orig_height: float = eye_left.size.y
	eye_left.size.y = 2
	eye_right.size.y = 2
	var tween := create_tween()
	tween.tween_property(eye_left, "size:y", orig_height, 0.1)
	tween.parallel().tween_property(eye_right, "size:y", orig_height, 0.1)

func _on_expression_changed(expression: String) -> void:
	current_expression = expression
	_update_expression_visual()

func _update_expression_visual() -> void:
	var color: Color = NOMIExpressions.get_color(current_expression)
	if avatar_panel:
		var sb: StyleBoxFlat = avatar_panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		if sb:
			sb.border_color = color
			avatar_panel.add_theme_stylebox_override("panel", sb)

	# Update eye shape based on expression
	var eye_state: Dictionary = NOMIExpressions.get_eye_state(current_expression)
	if eye_state.shape == "wide":
		eye_left.size = Vector2(14, 20)
		eye_right.size = Vector2(14, 20)
	elif eye_state.shape == "narrow":
		eye_left.size = Vector2(14, 10)
		eye_right.size = Vector2(14, 10)
	elif eye_state.shape == "happy":
		eye_left.size = Vector2(14, 8)
		eye_right.size = Vector2(14, 8)
	else:
		eye_left.size = Vector2(12, 16)
		eye_right.size = Vector2(12, 16)

	# Update blink behavior based on expression
	if "blink" in eye_state:
		blink_interval = 2.0 if eye_state.blink else 5.0

	# Update mouth shape
	var mouth_state: Dictionary = NOMIExpressions.get_mouth_state(current_expression)
	if mouth_state.shape == "smile":
		mouth.size = Vector2(20, 8)
	elif mouth_state.shape == "smile_wide":
		mouth.size = Vector2(26, 10)
	elif mouth_state.shape == "o":
		mouth.size = Vector2(12, 12)
	else:
		mouth.size = Vector2(20, 6)

func _on_commentary_requested(text: String, duration: float) -> void:
	if not speech_bubble or not speech_label:
		return

	# Kill any in-flight commentary tween
	if speech_tween and speech_tween.is_valid():
		speech_tween.kill()

	speech_label.text = text
	speech_bubble.visible = true

	# Auto-size bubble to text
	var font: Font = speech_label.get_theme_font("font")
	if font:
		var text_size: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
		var bubble_width: float = minf(text_size.x + 40, BUBBLE_MAX_WIDTH)
		speech_bubble.size.x = bubble_width

	# Fade in
	speech_bubble.modulate.a = 0.0
	speech_tween = create_tween()
	speech_tween.tween_property(speech_bubble, "modulate:a", 1.0, 0.2)

	# Fade out after duration
	speech_tween.tween_interval(duration)
	speech_tween.tween_property(speech_bubble, "modulate:a", 0.0, 0.3)
	speech_tween.tween_callback(func(): speech_bubble.visible = false)
