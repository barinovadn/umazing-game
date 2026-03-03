extends Node
## Basic custom hardware cursor with 2 states.


var point = load("res://autoload/cursor/cursor_point.png")
var click = load("res://autoload/cursor/cursor_click.png")


func _ready():
	Input.set_custom_mouse_cursor(point)
	Input.set_custom_mouse_cursor(point, Input.CURSOR_POINTING_HAND)


func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			Input.set_custom_mouse_cursor(click)
		else:
			Input.set_custom_mouse_cursor(point)
