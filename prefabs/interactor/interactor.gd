@icon("interactor.png")
class_name Interactor
extends RayCast2D
## Fires a ray in the [member character]'s facing direction to interact with
## [Interactable] objects.


signal interacted() ## Emitted when a successful interaction occurs.


## Input action name that triggers [method interact].
@export var action: String

## Current facing direction of the interactor.
## [br][br][b]NOTE[/b]: Updates [member target_position].
## By default is set to  match the initial [member target_position].
var direction: Vector2:
	set(value):
<<<<<<< Updated upstream
		direction = value
		_update_target_position()
## Length of the interaction ray in pixels.
## [br][br][b]NOTE[/b]: Updates [member target_position].
## By default is set to  match the initial [member target_position].
var length: float = -1:
=======
		_direction = value
		target_position = _direction * _length

## Length of the interaction ray in pixels.
## [br][br][b]NOTE[/b]: Updates [member target_position].
## By default is set to  match the initial [member target_position].
var length: float:
	get:
		return _length
>>>>>>> Stashed changes
	set(value):
		length = value
		_update_target_position()


func _ready():
	var origin_target_position := target_position
	
	length = Vector2.ZERO.distance_to(origin_target_position)
	direction = Vector2.ZERO.direction_to(origin_target_position)


func _input(event: InputEvent):
	if event.is_action_pressed(action):
		interact()


<<<<<<< Updated upstream
func _update_target_position():
	target_position = direction * length
=======
## Attempts to interact with the the first object found by [method RayCast2D.get_collider].
## Returns the found [Interactable] if interaction was successful,
## [code]null[/code] otherwise. Emits [signal interacted] on success.
func interact() -> Interactable:
	_current_interactable = _find_closest_interactable()
	var interactable := _current_interactable
	if interactable == null:
		interactable = get_collider() as Interactable
	if interactable == null or not interactable.interact():
		return null
>>>>>>> Stashed changes


## Attempts to interact with the the first object found by [method RayCast2D.get_collider].
## Returns the found [Interactable] if interaction was successful,
## [code]null[/code] otherwise. Emits [signal interacted] on success.
func interact() -> Interactable:
	var interactable := get_collider() as Interactable
	
	if not interactable or not interactable.interact():
		return null
	
	interacted.emit()
	return interactable
