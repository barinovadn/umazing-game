@icon("inspectable.png")
class_name Inspectable
extends Interactable
## Displays a random [member description] when interacted with.


## List of possible description texts.
## A random entry is chosen when the object is inspected using [method interact].
@export var description: Array[String] = ["..."]


func _on_interaction():
	if description.is_empty():
		return false

	var text: String = description.pick_random()

	var ds = get_tree().get_first_node_in_group("dialogue_system")
	if ds == null:
		var nodes := get_tree().get_nodes_in_group("dialogue_system")
		if nodes.size() > 0:
			ds = nodes[0]

	if ds != null and ds.has_method("say"):
		ds.say(self, text)
	else:
		print('"', text, '"')

	return true
