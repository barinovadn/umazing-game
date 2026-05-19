@icon("inspectable.png")
class_name Inspectable
extends Interactable


enum Mode { Single, Sequence }
enum Order { Random, SequentialAscending, SequentialDescending }

@export var dialogues: Array[Dialogue]
@export var mode: Mode
@export var order: Order
@export var preset: Dialogue ## Default [member Dialogue.fallback] for [member dialogues].

var _sequence_index: int = -1


func _on_interaction() -> bool:
	if not len(dialogues):
		return false
	
	inspect()
	return true


func _resolve_preset():
	for dialogue in dialogues:
		if not dialogue.fallback:
			dialogue.fallback = preset


func _resolve_dialogue() -> Dialogue:
	if len(dialogues) <= 0:
		return null
	
	match order:
		Order.Random:
			return dialogues.pick_random()
		Order.SequentialAscending:
			return _resolve_dialogue_sequential_mode(1)
		Order.SequentialDescending:
			return _resolve_dialogue_sequential_mode(-1)
	
	return null


func _resolve_dialogue_sequential_mode(step: int = 1) -> Dialogue:
	if len(dialogues) <= 0:
		return null
	elif len(dialogues) == 1:
		_sequence_index = 0
		return dialogues[0]
	
	_sequence_index += step
	
	if _sequence_index >= len(dialogues):
		_sequence_index = 0
	elif _sequence_index < 0:
		_sequence_index = len(dialogues)-1
	
	return dialogues[_sequence_index]


func _resolve_dialogues() -> Array[Dialogue]:
	if len(dialogues) <= 0:
		return []
	
	match order:
		Order.Random:
			var dialogues_shuffled := dialogues.duplicate()
			dialogues_shuffled.shuffle()
			return dialogues_shuffled
		Order.SequentialAscending:
			return dialogues
		Order.SequentialDescending:
			var dialogues_reversed := dialogues.duplicate()
			dialogues_reversed.reverse()
			return dialogues_reversed
	
	return []


func inspect():
	if len(dialogues) <= 0:
		return
	
	_resolve_preset()
	
	match mode:
		Mode.Single:
			Game.dialogue_system.display(_resolve_dialogue())
		Mode.Sequence:
			Game.dialogue_system.queue_dialogues(_resolve_dialogues())
