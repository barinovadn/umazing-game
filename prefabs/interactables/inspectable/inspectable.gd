@icon("inspectable.png")
class_name Inspectable
extends Interactable
## Displays a random [member description] when interacted with.


## List of possible description texts.
## A random entry is chosen when the object is inspected using [method interact].
@export var description: Array[String] = ["..."]


func _on_interaction():
	if not description:
		return false
	
	SceneManager.goto_scene("res://scenes/game/fights/cat_fight_scene.tscn")
	
	print('"', description.pick_random(), '"')
	
	return true
