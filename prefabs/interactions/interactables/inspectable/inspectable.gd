@icon("inspectable.png")
class_name Inspectable
extends Interactable


@export var dialogues: Array[Dialogue]
@export var preset: Dialogue ## Default [member Dialogue.fallback] for [member dialogues].


func _on_interaction() -> bool:
	if not len(dialogues):
		return false
	
	_resolve_preset()
	
	Game.dialogue_system.display(dialogues.pick_random())
	return true


func _resolve_preset():
	for dialogue in dialogues:
		if not dialogue.fallback:
			dialogue.fallback = preset
