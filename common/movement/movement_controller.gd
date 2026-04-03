@icon("movement_controller.png")
class_name MovementController2D
extends Node
## Base movement controller for any [Node2D].


## Emitted whenever character moves.
signal moved(direction: Vector2, speed: float)
## Emitted when character starts moving.
signal movement_started()
## Emitted when character stops moving.
signal movement_stopped()
## Emitted when [member direction] changes value.
signal direction_changed(direction: Vector2)
## Emitted when [member movement_enabled] changes value.
signal movement_toggled(enabled: bool)
## Emitted when character is teleported using [method teleport].
signal teleported(new_position: Vector2)


@export_group("Movement", "movement")
## Character movement speed in pixels per second.
@export var movement_speed: float = 100.0
## If set to [code]false[/code] movement is disabled and [method stop] is called.
@export var movement_enabled: bool = true:
	set(value):
		if movement_enabled != value:
			movement_enabled = value
			movement_toggled.emit(value)
			
			if not movement_enabled:
				stop()

## The direction character is currently moving in if [member is_moving] is
## [code]true[/code], the direction character last moved in otherwise.
var direction: Vector2 = Vector2.ZERO:
	set(value):
		if value == direction:
			return
		
		direction = value
		direction_changed.emit(direction)
## Whether the character is currently moving.
## Emits [signal movement_started] & [signal movement_stopped] when changed.
var is_moving: bool = false:
	set(value):
		if value == is_moving:
			return
		
		is_moving = value
		if is_moving:
			movement_started.emit()
		else:
			movement_stopped.emit()


## Moves the character by [param speed] amount in the current [member direction].
## If [param new_direction] is not [code]Vector2.ZERO[/code] will update
## [member direction]. Emits [signal moved].
func move(speed: float = movement_speed, new_direction: Vector2 = Vector2.ZERO):
	if not movement_enabled:
		return
	
	if new_direction:
		direction = new_direction
	
	if not speed or not direction:
		return
	
	is_moving = true
	moved.emit(direction, speed)

## Updates [member is_moving].
func stop():
	is_moving = false


## Emits [signal teleported].
func teleport(new_position: Vector2):
	teleported.emit(new_position)
