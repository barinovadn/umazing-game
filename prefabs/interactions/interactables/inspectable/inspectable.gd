@icon("inspectable.png")
class_name Inspectable
extends Interactable


@export var dialogues: Array[Dialogue]


func _on_interaction() -> bool:
	if not len(dialogues):
		return false
	
	Game.dialogue_system.display(dialogues.pick_random())
	return true
