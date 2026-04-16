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
var _default_label_settings: LabelSettings
var _default_bubble_style: StyleBox


func _ready() -> void:
	modulate = Color(modulate.r, modulate.g, modulate.b, 0.0)
	_default_label_settings = _label.label_settings
	_default_bubble_style = get_theme_stylebox("panel")


func show_for(target: CanvasItem, text: String, duration: float = -1.0, style: DialogueStyle = null) -> void:
	_target = target
	_apply_style(style)
	_label.text = text
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.custom_minimum_size.x = max_width
	await get_tree().process_frame
	_update_position()
	_play_visibility_tween(_resolve_duration(text, duration))


func _process(_delta: float) -> void:
	if _target == null:
		return
	if not is_instance_valid(_target):
		queue_free()
		return
	_update_position()


func _apply_style(style: DialogueStyle) -> void:
	_label.label_settings = _default_label_settings
	remove_theme_stylebox_override("panel")
	if _default_bubble_style != null:
		add_theme_stylebox_override("panel", _default_bubble_style)

	if style == null:
		return

	if style.bubble_label_settings != null:
		_label.label_settings = style.bubble_label_settings
	if style.bubble_style != null:
		add_theme_stylebox_override("panel", style.bubble_style)


func _play_visibility_tween(duration: float) -> void:
	if _tween != null:
		_tween.kill()
		_tween = null

	var fade_in_color := modulate
	fade_in_color.a = 1.0
	var fade_out_color := modulate
	fade_out_color.a = 0.0

	_tween = create_tween()
	_tween.tween_property(self, "modulate", fade_in_color, fade_time)
	_tween.tween_interval(duration)
	_tween.tween_property(self, "modulate", fade_out_color, fade_time)
	_tween.tween_callback(queue_free)


func _resolve_duration(text: String, duration: float) -> float:
	if duration > 0.0:
		return duration
	return max(base_duration, float(text.length()) * seconds_per_char)


func _update_position() -> void:
	var screen_pos := _target.get_global_transform_with_canvas().origin
	var desired := screen_pos + offset - Vector2(size.x * 0.5, size.y)
	var viewport_size := get_viewport_rect().size
	desired.x = clampf(desired.x, screen_margin, viewport_size.x - size.x - screen_margin)
	desired.y = clampf(desired.y, screen_margin, viewport_size.y - size.y - screen_margin)
	global_position = desired.round()
