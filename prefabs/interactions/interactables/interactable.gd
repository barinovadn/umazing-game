@icon("interactable.png")
class_name Interactable
extends StaticBody2D
## Base class for all objects that the player can interact with using "E".


signal interacted() ## Emitted after every successful interaction.
signal interaction_limit_reached() ## Emitted once the interaction limit reached.

## Calls [method delete] whenever [member enabled] is set to [code]false[/code].
@export var delete_on_disable: bool
## If set to [code]false[/code] the [method interact] will always ignore calls.
@export var enabled: bool = true:
	set(value):
		enabled = value
		if delete_on_disable and not enabled:
			delete()
## The maximum number of interactions possible.
## Once reached [member enabled] is set to [code]false[/code].
@export var interaction_limit: int = 0
@export var cooldown_duration: float = 0.0

@onready var _cooldown_timer: Timer = %Cooldown

var interaction_count: int:
	set(value):
		interaction_count = value
		if interaction_limit > 0 and interaction_count >= interaction_limit:
			enabled = false
			interaction_limit_reached.emit()
var is_on_cooldown: bool:
	get(): return not _cooldown_timer.is_stopped() if _cooldown_timer else false


func _on_interaction() -> bool:
	return true


## Attempts to perform the interaction.
## Returns [code]true[/code] if interaction succeeded, [code]false[/code] otherwise.
## Interaction fails if [member enabled] is [code]false[/code] or the internal
## [method _on_interaction] returns [code]false[/code].
## Emits [signal interacted] when successful.
func interact() -> bool:
	if not enabled or is_on_cooldown or not _on_interaction():
		return false
	
	interaction_count += 1
	interacted.emit()
	if cooldown_duration > 0:
		_cooldown_timer.start(cooldown_duration)
	return true


## Queue free.
func delete():
	queue_free()
