extends PanelContainer
class_name InteractionPrompt

@export var default_offset: Vector2 = Vector2(0, -6)
@export var y_offset: float = 115.0

@onready var _label: Label = %Label

var _target: CanvasItem
var _offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	hide_now()


func show_for(target: CanvasItem, prompt_text: String = "E", custom_offset: Vector2 = Vector2(0, -6)) -> void:
	if target == null or _label == null:
		hide_now()
		return

	_target = target
	_offset = custom_offset
	_label.text = prompt_text
	visible = true
	_update_position()


func hide_now() -> void:
	_target = null
	visible = false


func _process(_delta: float) -> void:
	if not visible:
		return
	if _target == null or not is_instance_valid(_target):
		hide_now()
		return
	_update_position()


func _update_position() -> void:
	var world_anchor := _get_target_world_anchor()
	var screen_anchor := get_viewport().get_canvas_transform() * world_anchor
	global_position = (screen_anchor + Vector2(-size.x * 0.5, -size.y + y_offset)).round()


func _get_target_world_anchor() -> Vector2:
	if _target == null:
		return Vector2.ZERO

	if _target is Control:
		return (_target as Control).global_position + _offset

	var node := _target as Node2D
	if node == null:
		return Vector2.ZERO

	var world_position := node.global_position + _offset
	var sprite := node.find_child("Sprite2D", true, false) as Sprite2D
	if sprite != null and sprite.texture != null:
		world_position.y -= sprite.texture.get_size().y * sprite.scale.y * 0.5
		return world_position

	var animated := node.find_child("AnimatedSprite2D", true, false) as AnimatedSprite2D
	if animated != null and animated.sprite_frames != null:
		var frame_texture := animated.sprite_frames.get_frame_texture(animated.animation, animated.frame)
		if frame_texture != null:
			world_position.y -= frame_texture.get_size().y * animated.scale.y * 0.5

	return world_position
