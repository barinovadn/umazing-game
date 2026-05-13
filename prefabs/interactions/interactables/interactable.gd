@icon("interactable.png")
class_name Interactable
extends StaticBody2D
## Base class for all objects that the player can interact with using "E".


signal interacted() ## Emitted after every successful interaction.

## If set to [code]false[/code] the [method interact] will always ignore calls.
@export var enabled: bool = true


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
	
	interacted.emit()
	return true
