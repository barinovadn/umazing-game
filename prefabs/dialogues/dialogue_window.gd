extends Control
class_name DialogueWindow

const PORTRAIT_CUTOUT_SHADER := preload("res://prefabs/dialogues/portrait_cutout.gdshader")
const LABEL_TITLE: LabelSettings = preload("res://common/theme/label_title.tres")
const LABEL_DESC: LabelSettings = preload("res://common/theme/label_desc.tres")
const DIALOGUE_FONT: FontFile = preload("res://common/theme/fonts/minecraftfont.ttf")

const BACKGROUND_NPC: Texture2D = preload("res://prefabs/dialogues/styles/npc_default_bg.png")
const BACKGROUND_PLAYER: Texture2D = preload("res://prefabs/dialogues/styles/player_bg.png")
const BACKGROUND_CAT_WOOD: Texture2D = preload("res://prefabs/dialogues/styles/cat_wood_bg.png")
const BACKGROUND_PIG_BARN: Texture2D = preload("res://prefabs/dialogues/styles/pig_barn_bg.png")
const BACKGROUND_NINJA_NIGHT: Texture2D = preload("res://prefabs/dialogues/styles/ninja_night_bg.png")
var _current_portrait_scale: float = 1.0

@export var base_duration: float = 2.4
@export var seconds_per_char: float = 0.04
@export var fade_time: float = 0.15

@onready var _panel: PanelContainer = %Panel
@onready var _background_texture: TextureRect = %BackgroundTexture
@onready var _background_tint: ColorRect = %BackgroundTint
@onready var _accent_bar: ColorRect = %AccentBar
@onready var _portrait_frame: PanelContainer = %PortraitFrame
@onready var _portrait: TextureRect = %Portrait
@onready var _name_label: Label = %NameLabel
@onready var _text_label: Label = %TextLabel

var _tween: Tween



func _refresh_text_rendering() -> void:
	if _name_label.label_settings != null:
		_name_label.label_settings = _name_label.label_settings.duplicate()
	if _text_label.label_settings != null:
		_text_label.label_settings = _text_label.label_settings.duplicate()

	_name_label.position = _name_label.position.round()
	_text_label.position = _text_label.position.round()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	modulate = Color(1.0, 1.0, 1.0, 0.0)

	var title_settings: LabelSettings = LABEL_TITLE.duplicate()
	title_settings.font = DIALOGUE_FONT
	title_settings.font_size = 20
	title_settings.line_spacing = 0.0
	title_settings.outline_size = 0
	title_settings.font_color = Color("#4a3218")

	var desc_settings: LabelSettings = LABEL_DESC.duplicate()
	desc_settings.font = DIALOGUE_FONT
	desc_settings.font_size = 18
	desc_settings.line_spacing = 0.0
	desc_settings.outline_size = 0
	desc_settings.font_color = Color("#6a4a22")

	_name_label.label_settings = title_settings
	_text_label.label_settings = desc_settings	
	_name_label.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_text_label.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	_name_label.position = _name_label.position.round()
	_text_label.position = _text_label.position.round()

	_background_texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_background_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background_texture.stretch_mode = TextureRect.STRETCH_SCALE

	if _portrait != null:
		_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		var portrait_material := ShaderMaterial.new()
		portrait_material.shader = PORTRAIT_CUTOUT_SHADER
		portrait_material.set_shader_parameter("key_color", Color(0.02, 0.05, 0.07, 1.0))
		portrait_material.set_shader_parameter("threshold", 0.1)
		_portrait.material = portrait_material

	set_preset("npc")


func show_dialogue(text: String, portrait: Texture2D = null, speaker_name: String = "", duration: float = -1.0) -> void:
	_text_label.text = text

	_portrait.texture = portrait
	_portrait_frame.visible = portrait != null

	speaker_name = speaker_name.strip_edges()
	_name_label.text = speaker_name
	_name_label.visible = not speaker_name.is_empty()
	_refresh_text_rendering()

	visible = true

	if _tween != null:
		_tween.kill()
		_tween = null

	var c_in := modulate
	c_in.a = 1.0
	var c_out := modulate
	c_out.a = 0.0

	var final_duration := duration
	if final_duration <= 0.0:
		final_duration = max(base_duration, float(text.length()) * seconds_per_char)

	_tween = create_tween()
	_tween.tween_property(self, "modulate", c_in, fade_time)
	_tween.tween_interval(final_duration)
	_tween.tween_property(self, "modulate", c_out, fade_time)
	_tween.tween_callback(_hide)


func hide_now() -> void:
	if _tween != null:
		_tween.kill()
		_tween = null
	_hide()


func _hide() -> void:
	visible = false

func set_preset(preset: String) -> void:
	var style := _resolve_style(preset)

	_background_texture.texture = style["background_texture"]
	_background_tint.color = style["tint_color"]
	_accent_bar.color = style["accent_color"]

	var name_settings: LabelSettings = _name_label.label_settings.duplicate()
	name_settings.font_color = style["name_color"]
	name_settings.outline_size = 0
	_name_label.label_settings = name_settings

	var text_settings: LabelSettings = _text_label.label_settings.duplicate()
	text_settings.font_color = style["text_color"]
	text_settings.outline_size = 0
	_text_label.label_settings = text_settings

	_name_label.modulate = Color.WHITE
	_text_label.modulate = Color.WHITE
	_refresh_text_rendering()

	_panel.add_theme_stylebox_override("panel", _create_panel_style(style))
	_portrait_frame.add_theme_stylebox_override("panel", _create_portrait_style(style))

	_panel.add_theme_stylebox_override("panel", _create_panel_style(style))
	_portrait_frame.add_theme_stylebox_override("panel", _create_portrait_style(style))

	_panel.add_theme_stylebox_override("panel", _create_panel_style(style))
	_portrait_frame.add_theme_stylebox_override("panel", _create_portrait_style(style))
	_current_portrait_scale = float(style.get("portrait_scale", 1.0))
	_apply_portrait_scale_deferred.call_deferred()

func _apply_portrait_scale_deferred() -> void:
	await get_tree().process_frame

	if _portrait == null:
		return

	_portrait.pivot_offset = _portrait.size * 0.5
	_portrait.scale = Vector2(_current_portrait_scale, _current_portrait_scale)
	
func _resolve_style(preset: String) -> Dictionary:
	match preset:
		"player":
			return {
				"background_texture": BACKGROUND_PLAYER,
				"tint_color": Color(0.08, 0.16, 0.10, 0.18),
				"accent_color": Color("#b8e070"),
				"name_color": Color("#4d6a2a"),
				"text_color": Color("#6f8f3b"),
				"panel_fill_color": Color(0.03, 0.06, 0.04, 0.10),
				"panel_border_color": Color("#d8eeb0"),
				"frame_fill_color": Color(0.03, 0.06, 0.04, 0.30),
				"frame_border_color": Color("#eff9cf"),
			}
		"cat_wood", "quest":
			return {
				"background_texture": BACKGROUND_CAT_WOOD,
				"tint_color": Color(0.12, 0.05, 0.02, 0.12),
				"accent_color": Color("#f6c97a"),
				"name_color": Color("#5a3518"),
				"text_color": Color("#7b4d22"),
				"panel_fill_color": Color(0.10, 0.05, 0.02, 0.10),
				"panel_border_color": Color("#ffe2ab"),
				"frame_fill_color": Color.BLACK,
				"frame_border_color": Color("#fff0cc"),
			}
		"pig_barn":
			return {
				"background_texture": BACKGROUND_PIG_BARN,
				"tint_color": Color(0.16, 0.08, 0.02, 0.12),
				"accent_color": Color("#ffd36d"),
				"name_color": Color("#5a3510"),
				"text_color": Color("#7a4a16"),
				"panel_fill_color": Color(0.14, 0.07, 0.01, 0.08),
				"panel_border_color": Color("#ffe1a3"),
				"frame_fill_color": Color.BLACK,
				"frame_border_color": Color("#fff0c3"),
				"portrait_scale": 0.9,
			}
		"ninja_night":
			return {
				"background_texture": BACKGROUND_NINJA_NIGHT,
				"tint_color": Color(0.02, 0.03, 0.10, 0.12),
				"accent_color": Color("#8cb2ff"),
				"name_color": Color("#103fa2"),
				"text_color": Color("#e4efff"),
				"panel_fill_color": Color(0.02, 0.03, 0.08, 0.08),
				"panel_border_color": Color("#bad2ff"),
				"frame_fill_color": Color.BLACK,
				"frame_border_color": Color("#e1ecff"),
				"portrait_scale": 0.9,
			}
		_:
			return {
				"background_texture": BACKGROUND_NPC,
				"tint_color": Color(0.15, 0.08, 0.03, 0.12),
				"accent_color": Color("#f1c786"),
				"name_color": Color("#5a3518"),
				"text_color": Color("#7b4d22"),
				"panel_fill_color": Color(0.10, 0.05, 0.02, 0.10),
				"panel_border_color": Color("#ffe2b5"),
				"frame_fill_color": Color.BLACK,
				"frame_border_color": Color("#fff0d0"),
				"portrait_scale": 1.0,
			}


func _create_panel_style(style: Dictionary) -> StyleBoxFlat:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = style["panel_fill_color"]
	panel_style.border_color = style["panel_border_color"]
	panel_style.border_width_left = 4
	panel_style.border_width_top = 4
	panel_style.border_width_right = 4
	panel_style.border_width_bottom = 4
	panel_style.corner_radius_top_left = 16
	panel_style.corner_radius_top_right = 16
	panel_style.corner_radius_bottom_right = 16
	panel_style.corner_radius_bottom_left = 16
	panel_style.shadow_color = Color(0, 0, 0, 0.32)
	panel_style.shadow_size = 4
	panel_style.content_margin_left = 0.0
	panel_style.content_margin_top = 0.0
	panel_style.content_margin_right = 0.0
	panel_style.content_margin_bottom = 0.0
	return panel_style


func _create_portrait_style(style: Dictionary) -> StyleBoxFlat:
	var portrait_style := StyleBoxFlat.new()
	portrait_style.bg_color = style["frame_fill_color"]
	portrait_style.border_color = style["frame_border_color"]
	portrait_style.border_width_left = 4
	portrait_style.border_width_top = 4
	portrait_style.border_width_right = 4
	portrait_style.border_width_bottom = 4
	portrait_style.corner_radius_top_left = 14
	portrait_style.corner_radius_top_right = 14
	portrait_style.corner_radius_bottom_right = 14
	portrait_style.corner_radius_bottom_left = 14
	portrait_style.shadow_color = Color(0, 0, 0, 0.25)
	portrait_style.shadow_size = 3
	portrait_style.content_margin_left = 0.0
	portrait_style.content_margin_top = 0.0
	portrait_style.content_margin_right = 0.0
	portrait_style.content_margin_bottom = 0.0
	return portrait_style
