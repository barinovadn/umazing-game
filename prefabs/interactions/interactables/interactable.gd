@icon("interactable.png")
class_name Interactable
extends StaticBody2D
## Base class for all objects that the player can interact with using "E".


signal interacted() ## Emitted after every successful interaction.
signal interaction_limit_reached() ## Emitted once the interaction limit reached.

## If set to [code]false[/code] the [method interact] will always ignore calls.
@export var enabled: bool = true
## The maximum number of interactions possible.
## Once reached [member enabled] is set to [code]false[/code].
@export var interaction_limit: int = 0

var interaction_count: int:
	set(value):
		interaction_count = value
		if interaction_limit > 0 and interaction_count >= interaction_limit:
			enabled = false
			interaction_limit_reached.emit()


func _on_interaction() -> bool:
	return true


## Attempts to perform the interaction.
## Returns [code]true[/code] if interaction succeeded, [code]false[/code] otherwise.
## Interaction fails if [member enabled] is [code]false[/code] or the internal
## [method _on_interaction] returns [code]false[/code].
## Emits [signal interacted] when successful.
func interact() -> bool:
	if not enabled or not _on_interaction():
		return false
	
	interaction_count += 1
	interacted.emit()
	return true
