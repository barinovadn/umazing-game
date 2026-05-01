extends CanvasLayer
class_name DialogueSystem

signal dialogue_window_closed

@export var bubble_scene: PackedScene
@export var window_scene: PackedScene
@export var default_style: DialogueStyle
@export var styles: Array[DialogueStyle] = []
@export var one_bubble_per_target: bool = true

var _styles_by_id: Dictionary = {}
var _bubbles_by_target_id: Dictionary = {}
var _dialogue_window: DialogueWindow
var _movement_blocked: bool = false
var _sequence_movement_blocked: bool = false


func _ready() -> void:
	add_to_group("dialogue_system")
	_rebuild_style_cache()


func say(target: CanvasItem, text: String, duration: float = -1.0, preset: String = "npc") -> void:
	if target == null or text.strip_edges().is_empty() or bubble_scene == null:
		return

	if one_bubble_per_target:
		_clear_existing_bubble(target)

	var bubble := bubble_scene.instantiate() as SpeechBubble
	if bubble == null:
		return

	add_child(bubble)
	bubble.show_for(target, text, duration, _resolve_style(preset))

	if one_bubble_per_target:
		_bubbles_by_target_id[target.get_instance_id()] = bubble


func clear_for(target: CanvasItem) -> void:
	if target == null:
		return
	_clear_existing_bubble(target)


func show_dialogue_window(
	text: String,
	portrait: Texture2D = null,
	speaker_name: String = "",
	duration: float = -1.0,
	preset: String = "",
	block_movement: bool = false,
	name_font_size: int = -1,
	text_font_size: int = -1,
	close_mode: int = 0,
	allow_skip: bool = true
) -> void:
	if text.strip_edges().is_empty():
		return

	var dialogue_window := _get_dialogue_window()
	if dialogue_window == null:
		return

	_movement_blocked = block_movement
	dialogue_window.show_dialogue(
		text,
		portrait,
		speaker_name,
		duration,
		_resolve_style(preset),
		name_font_size,
		text_font_size,
		close_mode,
		allow_skip
	)


func show_dialogue_request(request, target: CanvasItem = null) -> void:
	if request == null:
		return

	var text: String = String(request.get_text()).strip_edges()
	if text.is_empty():
		return

	if int(request.display_mode) == 1:
		show_dialogue_window(
			text,
			request.portrait,
			request.speaker_name,
			request.duration,
			request.preset,
			request.block_movement,
			request.name_font_size,
			request.text_font_size,
			int(request.close_mode),
			request.allow_skip
		)
	else:
		if target == null:
			return
		say(target, text, request.duration, request.preset)



func clear_dialogue_window() -> void:
	if _dialogue_window != null and is_instance_valid(_dialogue_window):
		_dialogue_window.hide_now()


func is_movement_blocked() -> bool:
	return _movement_blocked or _sequence_movement_blocked
	
func set_sequence_movement_blocked(blocked: bool) -> void:
	_sequence_movement_blocked = blocked


func _on_dialogue_window_closed() -> void:
	_movement_blocked = false
	dialogue_window_closed.emit()


func _get_dialogue_window() -> DialogueWindow:
	if _dialogue_window != null and is_instance_valid(_dialogue_window):
		return _dialogue_window

	if window_scene == null:
		return null

	_dialogue_window = window_scene.instantiate() as DialogueWindow
	if _dialogue_window == null:
		return null

	add_child(_dialogue_window)

	if not _dialogue_window.closed.is_connected(_on_dialogue_window_closed):
		_dialogue_window.closed.connect(_on_dialogue_window_closed)

	return _dialogue_window


func _rebuild_style_cache() -> void:
	_styles_by_id.clear()

	for style in styles:
		if style == null:
			continue

		for id in style.ids:
			var key := String(id).strip_edges()
			if key.is_empty():
				continue
			_styles_by_id[StringName(key)] = style


func _resolve_style(preset: String) -> DialogueStyle:
	var key := StringName(preset.strip_edges())
	if not String(key).is_empty() and _styles_by_id.has(key):
		return _styles_by_id[key]
	return default_style


func _clear_existing_bubble(target: CanvasItem) -> void:
	var target_id := target.get_instance_id()
	if not _bubbles_by_target_id.has(target_id):
		return

	var bubble = _bubbles_by_target_id[target_id]
	if is_instance_valid(bubble):
		bubble.queue_free()

	_bubbles_by_target_id.erase(target_id)
