@icon("interactor.png")
class_name Interactor
extends RayCast2D
## Fires a ray in the [member character]'s facing direction to interact with
## [Interactable] objects.


signal interacted() ## Emitted when a successful interaction occurs.

## Input action name that triggers [method interact].
@export var action: String
@export var cooldown_duration: float = 0.0

@onready var _cooldown_timer: Timer = %Cooldown

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
var can_interract: bool = true
var is_on_cooldwon: bool:
	get(): return not _cooldown_timer.is_stopped() if _cooldown_timer else false


func _ready():
	var origin_target_position := target_position
	
	length = Vector2.ZERO.distance_to(origin_target_position)
	direction = Vector2.ZERO.direction_to(origin_target_position)


func _input(event: InputEvent):
	if event.is_action_pressed(action):
		interact()


func _update_target_position():
	target_position = direction * length


func set_on_cooldown():
	if cooldown_duration > 0:
		_cooldown_timer.start(cooldown_duration)


## Attempts to interact with the the first object found by [method RayCast2D.get_collider].
## Returns the found [Interactable] if interaction was successful,
## [code]null[/code] otherwise. Emits [signal interacted] on success.
func interact() -> Interactable:
	if not can_interract or is_on_cooldwon:
		return
	
	var interactable := get_collider() as Interactable
	
	if not interactable or not interactable.interact():
		return null
	
	interacted.emit()
	set_on_cooldown()
	return interactable
