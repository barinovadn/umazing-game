extends CanvasLayer
class_name DialogueSystem

@export var bubble_scene: PackedScene = preload("res://prefabs/dialogues/speech_bubble.tscn")
@export var window_scene: PackedScene = preload("res://prefabs/dialogues/dialogue_window.tscn")

@export var one_bubble_per_target: bool = true

var _bubbles_by_target_id: Dictionary = {}
var _dialogue_window: DialogueWindow

func _ready() -> void:
	add_to_group("dialogue_system")

func say(target: CanvasItem, text: String, duration: float = -1.0, preset: String = "npc") -> void:
	if target == null:
		return
	if text.strip_edges().is_empty():
		return

	if one_bubble_per_target:
		var tid := target.get_instance_id()
		if _bubbles_by_target_id.has(tid):
			var old_bubble = _bubbles_by_target_id[tid]
			if is_instance_valid(old_bubble):
				old_bubble.queue_free()
			_bubbles_by_target_id.erase(tid)

	var bubble := bubble_scene.instantiate()
	add_child(bubble)

	if bubble.has_method("set_preset"):
		bubble.set_preset(preset)

	bubble.show_for(target, text, duration)

	if one_bubble_per_target:
		_bubbles_by_target_id[target.get_instance_id()] = bubble

func clear_for(target: CanvasItem) -> void:
	if target == null:
		return
	var tid := target.get_instance_id()
	if _bubbles_by_target_id.has(tid):
		var b = _bubbles_by_target_id[tid]
		if is_instance_valid(b):
			b.queue_free()
		_bubbles_by_target_id.erase(tid)


func show_dialogue_window(text: String, portrait: Texture2D = null, speaker_name: String = "", duration: float = -1.0, preset: String = "npc") -> void:
	if text.strip_edges().is_empty():
		return

	var dialogue_window := _get_dialogue_window()
	if dialogue_window == null:
		return

	dialogue_window.set_preset(preset)
	dialogue_window.show_dialogue(text, portrait, speaker_name, duration)


func clear_dialogue_window() -> void:
	if _dialogue_window != null and is_instance_valid(_dialogue_window):
		_dialogue_window.hide_now()


func _get_dialogue_window() -> DialogueWindow:
	if _dialogue_window != null and is_instance_valid(_dialogue_window):
		return _dialogue_window
	if window_scene == null:
		return null

	_dialogue_window = window_scene.instantiate()
	add_child(_dialogue_window)
	return _dialogue_window
