extends PanelContainer
class_name InteractionPrompt


@export var default_offset: Vector2 = Vector2(0, -6)
const LABEL_TITLE: LabelSettings = preload("res://common/theme/label_title.tres")
const PROMPT_FONT: FontFile = preload("res://common/theme/fonts/minecraftfont.ttf")
@onready var _label: Label = %Label

var _target: CanvasItem = null
var _offset: Vector2 = Vector2.ZERO


func _get_target_world_anchor() -> Vector2:
	if _target == null:
		return Vector2.ZERO

	if _target is Node2D:
		var node := _target as Node2D
		var world_position := node.global_position + _offset

		var sprite_candidate := node.find_child("Sprite2D", true, false)
		if sprite_candidate == null:
			sprite_candidate = node.find_child("AnimatedSprite2D", true, false)

		if sprite_candidate is Sprite2D:
			var sprite := sprite_candidate as Sprite2D
			if sprite.texture != null:
				world_position.y -= sprite.texture.get_size().y * sprite.scale.y * 0.5

		elif sprite_candidate is AnimatedSprite2D:
			var animated := sprite_candidate as AnimatedSprite2D
			if animated.sprite_frames != null:
				var frame_texture := animated.sprite_frames.get_frame_texture(animated.animation, animated.frame)
				if frame_texture != null:
					world_position.y -= frame_texture.get_size().y * animated.scale.y * 0.5

		return world_position

	if _target is Control:
		return (_target as Control).global_position + _offset

	return Vector2.ZERO
	
	
func _apply_prompt_pixel_text() -> void:
	if _label == null:
		return

	get_viewport().gui_snap_controls_to_pixels = true
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	var prompt_settings := LABEL_TITLE.duplicate()
	prompt_settings.font = PROMPT_FONT
	prompt_settings.font_size = 18
	prompt_settings.line_spacing = 0.0
	prompt_settings.outline_size = 0
	prompt_settings.font_color = Color.BLACK
	_label.label_settings = prompt_settings
	_label.scale = Vector2.ONE
	_label.position = _label.position.round()
	_label.add_theme_constant_override("outline_size", 0)


func _ready() -> void:
	get_viewport().gui_snap_controls_to_pixels = true
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE
	style.border_color = Color.BLACK
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.shadow_color = Color(0, 0, 0, 0.30)
	style.shadow_size = 2
	add_theme_stylebox_override("panel", style)

	if _label != null:
		_apply_prompt_pixel_text()
		_label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_label.add_theme_color_override("font_color", Color.BLACK)
		_label.add_theme_color_override("font_outline_color", Color.WHITE)

	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide_now()



func show_for(target: CanvasItem, prompt_text: String = "E", custom_offset: Vector2 = default_offset) -> void:
	if target == null:
		hide_now()
		return

	if not is_node_ready() or _label == null:
		return

	_target = target
	_offset = custom_offset
	_label.text = prompt_text
	_label.position = _label.position.round()
	_apply_prompt_pixel_text()
	visible = true
	_update_position()


func hide_now() -> void:
	_target = null
	visible = false


func _update_position() -> void:
	if _target == null:
		return

	var world_anchor := _get_target_world_anchor()
	var screen_anchor := get_viewport().get_canvas_transform() * world_anchor

	global_position = (screen_anchor + Vector2(-size.x * 0.5, -size.y + 115)).round()

func _process(_delta: float) -> void:
	if visible:
		_update_position()
		global_position = global_position.round()
