extends Control
class_name DialogueWindow

signal closed

const CLOSE_MODE_AUTO_TIMER := 0
const CLOSE_MODE_BY_ACTION := 1
const CLOSE_MODE_MANUAL := 2

@export var base_duration: float = 2.4
@export var seconds_per_char: float = 0.04
@export var fade_time: float = 0.15
@export var close_action: StringName = &"interact"
@export var skip_action: StringName = &"ui_cancel"

@onready var _panel: Panel = %Panel
@onready var _portrait: TextureRect = %Portrait
@onready var _name_label: Label = %NameLabel
@onready var _text_label: Label = %TextLabel
@onready var _portrait_frame: PanelContainer = %PortraitFrame

var _tween: Tween
var _portrait_scale: float = 1.0
var _default_name_label_settings: LabelSettings
var _default_text_label_settings: LabelSettings
var _default_panel_style: StyleBox
var _close_mode: int = CLOSE_MODE_AUTO_TIMER
var _close_action_locked: bool = false
var _allow_skip: bool = true


func _ready() -> void:
	visible = false
	modulate = Color(1.0, 1.0, 1.0, 0.0)
	_default_name_label_settings = _name_label.label_settings
	_default_text_label_settings = _text_label.label_settings
	_default_panel_style = _panel.get_theme_stylebox("panel")

func show_dialogue(
	text: String,
	portrait: Texture2D = null,
	speaker_name: String = "",
	duration: float = -1.0,
	style: DialogueStyle = null,
	name_font_size: int = -1,
	text_font_size: int = -1,
	close_mode: int = CLOSE_MODE_AUTO_TIMER,
	allow_skip: bool = true
) -> void:
	_close_mode = close_mode
	_allow_skip = allow_skip
	_close_action_locked = (_close_mode == CLOSE_MODE_BY_ACTION)

	_apply_style(style, name_font_size, text_font_size)

	_text_label.text = text
	_portrait.texture = portrait
	_portrait_frame.visible = portrait != null

	_name_label.text = speaker_name.strip_edges()
	_name_label.visible = not _name_label.text.is_empty()

	_refresh_portrait_layout.call_deferred()

	visible = true
	_play_visibility_tween(_resolve_duration(text, duration))


func hide_now() -> void:
	var was_visible := visible or modulate.a > 0.0

	if _tween != null:
		_tween.kill()
		_tween = null

	_close_action_locked = false
	visible = false
	modulate = Color(1.0, 1.0, 1.0, 0.0)

	if was_visible:
		closed.emit()

func _apply_style(style: DialogueStyle, name_font_size: int = -1, text_font_size: int = -1) -> void:
	_name_label.label_settings = _default_name_label_settings
	_text_label.label_settings = _default_text_label_settings
	_portrait_scale = 1.0

	_name_label.remove_theme_font_size_override("font_size")
	_text_label.remove_theme_font_size_override("font_size")

	_panel.remove_theme_stylebox_override("panel")
	if _default_panel_style != null:
		_panel.add_theme_stylebox_override("panel", _default_panel_style)

	if style != null:
		if style.name_label_settings != null:
			_name_label.label_settings = style.name_label_settings

		if style.text_label_settings != null:
			_text_label.label_settings = style.text_label_settings

		if style.panel_style != null:
			_panel.add_theme_stylebox_override("panel", style.panel_style)

		_portrait_scale = style.portrait_scale

	_apply_font_size_override(_name_label, name_font_size)
	_apply_font_size_override(_text_label, text_font_size)
	
func _apply_font_size_override(label: Label, font_size: int) -> void:
	if font_size <= 0:
		return

	if label.label_settings != null:
		var settings := label.label_settings.duplicate() as LabelSettings
		if settings != null:
			settings.font_size = font_size
			label.label_settings = settings
			return

	label.add_theme_font_size_override("font_size", font_size)


func _play_visibility_tween(duration: float) -> void:
	if _tween != null:
		_tween.kill()
		_tween = null

	var color_in := modulate
	color_in.a = 1.0

	var color_out := modulate
	color_out.a = 0.0

	_tween = create_tween()
	_tween.tween_property(self, "modulate", color_in, fade_time)

	if _close_mode == CLOSE_MODE_AUTO_TIMER:
		_tween.tween_interval(duration)
		_tween.tween_property(self, "modulate", color_out, fade_time)
		_tween.tween_callback(hide_now)
		
func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	var close_action_name := String(close_action)
	var skip_action_name := String(skip_action)

	if _close_mode == CLOSE_MODE_BY_ACTION:
		if event.is_action_released(close_action_name):
			_close_action_locked = false
			return

		if not _close_action_locked and event.is_action_pressed(close_action_name):
			get_viewport().set_input_as_handled()
			hide_now()
			return

	if not _allow_skip:
		return

	if _close_mode == CLOSE_MODE_MANUAL:
		return

	if event.is_action_pressed(skip_action_name):
		get_viewport().set_input_as_handled()
		hide_now()


func _resolve_duration(text: String, duration: float) -> float:
	if duration > 0.0:
		return duration
	return max(base_duration, float(text.length()) * seconds_per_char)


func _refresh_portrait_layout() -> void:
	await get_tree().process_frame

	if _portrait == null or _portrait.texture == null:
		return

	_portrait.scale = Vector2.ONE * _portrait_scale
	var scaled_size := _portrait.size * _portrait_scale
	_portrait.position = (_portrait.size - scaled_size) * 0.5
