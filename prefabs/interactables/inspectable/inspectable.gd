@icon("inspectable.png")
class_name Inspectable
extends Interactable

@export_group("Dialogue")
@export var dialogue_request: Resource
@export var dialogue_requests: Array[Resource] = []
@export var current_dialogue_index: int = 0
@export var cycle_dialogue_requests_on_interact: bool = false


func _on_interaction() -> bool:
	var request = _resolve_dialogue_request()
	if request == null:
		return false

	var dialogue_system := get_tree().get_first_node_in_group("dialogue_system") as DialogueSystem
	if dialogue_system == null:
		return true

	dialogue_system.show_dialogue_request(request, self)
	_advance_dialogue_request_if_needed()
	return true


func set_dialogue_request_index(index: int) -> void:
	if dialogue_requests.is_empty():
		current_dialogue_index = 0
		return

	current_dialogue_index = clampi(index, 0, dialogue_requests.size() - 1)


func next_dialogue_request() -> void:
	if dialogue_requests.is_empty():
		return

	current_dialogue_index = wrapi(current_dialogue_index + 1, 0, dialogue_requests.size())


func _resolve_dialogue_request():
	if not dialogue_requests.is_empty():
		current_dialogue_index = clampi(current_dialogue_index, 0, dialogue_requests.size() - 1)
		return dialogue_requests[current_dialogue_index]

	return dialogue_request


func _advance_dialogue_request_if_needed() -> void:
	if not cycle_dialogue_requests_on_interact:
		return
	if dialogue_requests.size() < 2:
		return

	current_dialogue_index = wrapi(current_dialogue_index + 1, 0, dialogue_requests.size())
