@icon("interactable.png")
class_name Interactable
extends StaticBody2D
## Base class for all objects that the player can interact with using "E".


signal interacted() ## Emitted after every successful interaction.

## If set to [code]false[/code] the [method interact] will always ignore calls.
@export var enabled: bool = true

@export_group("Interaction Prompt")
@export var prompt_target_path: NodePath
@export var prompt_offset: Vector2 = Vector2(0, -44)


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



func get_prompt_target() -> CanvasItem:
	if prompt_target_path != NodePath():
		var prompt_target := get_node_or_null(prompt_target_path)
		if prompt_target is CanvasItem:
			return prompt_target

	var parent := get_parent()
	if parent is Character2D:
		return parent

	return self


func get_prompt_offset() -> Vector2:
	return prompt_offset
