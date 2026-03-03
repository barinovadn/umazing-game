@icon("interactor.png")
class_name Interactor
extends RayCast2D
## Fires a ray in the [member character]'s facing direction to interact with
## [Interactable] objects.


signal interacted() ## Emitted when a successful interaction occurs.

## The character this interactor belongs to. Used to track facing direction.
## If not set, tries to use the parent node as character.
@export var character: Character2D:
	set(value):
		character = value
		_connect_character_signals()
## Input action name that triggers [method interact].
@export var action: String


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


func _ready():
	var origin_target_position := target_position
	
	length = Vector2.ZERO.distance_to(origin_target_position)
	direction = Vector2.ZERO.direction_to(origin_target_position)
	
	if not character:
		character = get_parent() as Character2D
	
	if not character:
		push_warning("\"character\" is not selected or found.")
	else:
		_connect_character_signals()


func _input(event: InputEvent):
	if event.is_action_pressed(action):
		interact()


func _connect_character_signals():
	if not character or not character.movement:
		push_warning("failed to connect signals,
			\"character\" and/or \"character.movement\" is null.")
		return
	
	var dir_changed_signal := character.movement.direction_changed
	
	if not dir_changed_signal.is_connected(_on_character_direction_changed):
		dir_changed_signal.connect(_on_character_direction_changed)


func _update_target_position():
	target_position = direction * length


func _on_character_direction_changed(new_direction: Vector2):
	direction = new_direction


## Attempts to interact with the the first object found by [method RayCast2D.get_collider].
## Returns the found [Interactable] if interaction was successful,
## [code]null[/code] otherwise. Emits [signal interacted] on success.
func interact() -> Interactable:
	var interactable := get_collider() as Interactable
	
	if not interactable or not interactable.interact():
		return null
	
	interacted.emit()
	return interactable
