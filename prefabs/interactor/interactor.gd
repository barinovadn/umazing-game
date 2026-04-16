@icon("interactor.png")
class_name Interactor
extends RayCast2D

signal interacted()

@export var action: String
@export var interaction_radius: float = 28.0
@export var prompt_text: String = "E"
@export var prompt_scene: PackedScene

var _direction: Vector2 = Vector2.DOWN
var _length: float = -1.0

var direction: Vector2:
	get:
		return _direction
	set(value):
		_direction = value
		target_position = _direction * _length

var length: float:
	get:
		return _length
	set(value):
		_length = value
		target_position = _direction * _length

var _current_interactable: Interactable
var _prompt: InteractionPrompt


func _ready() -> void:
	length = target_position.length()
	direction = Vector2.DOWN if length == 0.0 else target_position.normalized()
	_create_prompt.call_deferred()


func _process(_delta: float) -> void:
	_current_interactable = _find_closest_interactable()
	_update_prompt()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(action):
		interact()


func interact() -> Interactable:
	_current_interactable = _find_closest_interactable()
	var interactable := _current_interactable
	if interactable == null:
		interactable = get_collider() as Interactable
	if interactable == null or not interactable.interact():
		return null

	interacted.emit()
	return interactable


func _create_prompt() -> void:
	if prompt_scene == null or _prompt != null:
		return

	_prompt = prompt_scene.instantiate() as InteractionPrompt
	if _prompt == null:
		return

	var parent: Node = get_tree().get_first_node_in_group("dialogue_system")
	if parent == null:
		parent = get_tree().current_scene
	if parent == null:
		parent = get_parent()
	if parent != null:
		parent.add_child(_prompt)


func _update_prompt() -> void:
	if _prompt == null or not is_instance_valid(_prompt):
		return
	if _current_interactable == null:
		_prompt.hide_now()
		return

	var target := _current_interactable.get_prompt_target()
	if target == null:
		_prompt.hide_now()
		return

	_prompt.show_for(target, prompt_text, _current_interactable.get_prompt_offset())


func _find_closest_interactable() -> Interactable:
	force_raycast_update()

	var interactable := get_collider() as Interactable
	if interactable == null:
		return null

	if not is_instance_valid(interactable) or not interactable.is_inside_tree():
		return null

	if not interactable.enabled:
		return null

	if interactable is CanvasItem and not interactable.visible:
		return null

	if global_position.distance_squared_to(interactable.global_position) > interaction_radius * interaction_radius:
		return null

	return interactable
