extends PanelContainer
class_name SpeechBubble

@export var offset: Vector2 = Vector2(0, -36)
@export var max_width: float = 280.0

@export var base_duration: float = 1.6
@export var seconds_per_char: float = 0.035

@export var fade_time: float = 0.12
@export var screen_margin: float = 6.0

@onready var _label: Label = %Label

var _target: CanvasItem
var _tween: Tween

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate = Color(modulate.r, modulate.g, modulate.b, 0.0)

func show_for(target: CanvasItem, text: String, duration: float = -1.0) -> void:
	_target = target

	_label.text = text
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.custom_minimum_size.x = max_width

	await get_tree().process_frame
	_update_position()

	if _tween != null:
		_tween.kill()
		_tween = null

	var final_duration := duration
	if final_duration <= 0.0:
		final_duration = max(base_duration, float(text.length()) * seconds_per_char)

	var c_in := modulate
	c_in.a = 1.0
	var c_out := modulate
	c_out.a = 0.0

	_tween = create_tween()
	_tween.tween_property(self, "modulate", c_in, fade_time)
	_tween.tween_interval(final_duration)
	_tween.tween_property(self, "modulate", c_out, fade_time)
	_tween.tween_callback(queue_free)

func _process(_delta: float) -> void:
	if _target == null:
		return
	if not is_instance_valid(_target):
		queue_free()
		return
	_update_position()

func _update_position() -> void:
	var screen_pos: Vector2 = _target.get_global_transform_with_canvas().origin

	var desired := screen_pos + offset - Vector2(size.x * 0.5, size.y)

	var vp_size := get_viewport_rect().size
	desired.x = clampf(desired.x, screen_margin, vp_size.x - size.x - screen_margin)
	desired.y = clampf(desired.y, screen_margin, vp_size.y - size.y - screen_margin)

	global_position = desired

func set_preset(preset: String) -> void:
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(8)
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.border_width_top = 2
	sb.border_width_bottom = 2

	match preset:
		"player":
			sb.bg_color = Color("#2f6b4a")
			sb.border_color = Color("#1f3f2f")
		_:
			sb.bg_color = Color("#7a4a26")
			sb.border_color = Color("#4d2b14")

	add_theme_stylebox_override("panel", sb)
