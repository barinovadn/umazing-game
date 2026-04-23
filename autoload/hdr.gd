extends Node
## Turns on HDR 2D project setting at runtime.
##
## Currenly setting HDR to "on" also changes colors of the Godot editor itself,
## Which I personally find eye-popping (too bright and contrast to work with).


func _ready():
	get_viewport().use_hdr_2d = false


func _input(event: InputEvent):
	if event.is_action_pressed("hdr"):
		get_viewport().use_hdr_2d = !get_viewport().use_hdr_2d
