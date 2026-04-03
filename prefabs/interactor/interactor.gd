@icon("interactor.png")
class_name Interactor
extends RayCast2D
## Centralized player interaction helper.
## Supports proximity interaction from any side and shows a static "E" prompt
## over the closest valid interactable in range.


signal interacted() ## Emitted when a successful interaction occurs.


## Input action name that triggers [method interact].
@export var action: String

## Radius of the interaction search around the player in pixels.
@export var interaction_radius: float = 28.0

## Text shown in the interaction prompt.
@export var prompt_text: String = "E"

@export var prompt_scene: PackedScene = preload("res://prefabs/interactor/interaction_prompt.tscn")

## Current facing direction of the interactor.
## [br][br][b]NOTE[/b]: Updates [member target_position].
## By default is set to  match the initial [member target_position].
var direction: Vector2:
	set(value):
		direction = value
		_update_target_position()
## Length of the interaction ray in pixels.
## [br][br][b]NOTE[/b]: Updates [member target_position].
## By default is set to  match the initial [member target_position].
var length: float = -1:
	set(value):
		length = value
		_update_target_position()

var _current_interactable: Interactable
var _prompt: InteractionPrompt


func _ready():
	var origin_target_position := target_position
	
	length = Vector2.ZERO.distance_to(origin_target_position)
	direction = Vector2.ZERO.direction_to(origin_target_position)

	call_deferred("_ensure_prompt")


func _process(_delta: float) -> void:
	_update_current_interactable()
	_update_prompt()


func _input(event: InputEvent):
	if event.is_action_pressed(action):
		interact()


func _update_target_position():
	target_position = direction * length


## Attempts to interact with the closest [Interactable] in range.
## Returns the found [Interactable] if interaction was successful,
## [code]null[/code] otherwise. Emits [signal interacted] on success.
func interact() -> Interactable:
	_update_current_interactable()
	var interactable := _current_interactable

	if interactable == null:
		interactable = get_collider() as Interactable

	if interactable == null or not interactable.interact():
		return null
	
	interacted.emit()
	return interactable


func _update_current_interactable() -> void:
	_current_interactable = _find_closest_interactable()


func _find_closest_interactable() -> Interactable:
	var closest: Interactable
	var closest_distance_sq := interaction_radius * interaction_radius

	for node in get_tree().get_nodes_in_group("interactable"):
		var interactable := node as Interactable
		if interactable == null:
			continue
		if not is_instance_valid(interactable) or not interactable.is_inside_tree():
			continue
		if not interactable.enabled:
			continue
		if interactable is CanvasItem and not interactable.visible:
			continue

		var distance_sq := global_position.distance_squared_to(interactable.global_position)
		if distance_sq > closest_distance_sq:
			continue

		closest = interactable
		closest_distance_sq = distance_sq

	return closest


func _update_prompt() -> void:
	var prompt := _ensure_prompt()
	if prompt == null or not prompt.is_node_ready():
		return

	if _current_interactable == null:
		prompt.hide_now()
		return

	var target := _current_interactable.get_prompt_target()
	if target == null:
		prompt.hide_now()
		return

	prompt.show_for(target, prompt_text, _current_interactable.get_prompt_offset())


func _ensure_prompt() -> InteractionPrompt:
	if _prompt != null and is_instance_valid(_prompt):
		if _prompt.is_node_ready():
			return _prompt
		return null

	if prompt_scene == null:
		return null

	_prompt = prompt_scene.instantiate()

	var prompt_parent := get_tree().get_first_node_in_group("dialogue_system")
	if prompt_parent == null:
		prompt_parent = get_tree().current_scene
	if prompt_parent == null:
		prompt_parent = get_parent()

	if prompt_parent != null:
		prompt_parent.call_deferred("add_child", _prompt)

	return null
