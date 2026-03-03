@icon("movement_controller.png")
class_name MovementController2D
extends Node
## Base movement controller for the [CharacterBody2D].


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
signal teleported(new_position: Vector2, old_position: Vector2)

## The [CharacterBody2D] node this controller operates on.
## If not assigned, will attempt to use the parent node.
@export var character_body: CharacterBody2D

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
var is_moving: bool = false:
	set(value):
		if value == is_moving:
			return
		
		is_moving = value
		if is_moving:
			movement_started.emit()
		else:
			movement_stopped.emit()


func _ready():
	if not character_body:
		character_body = get_parent() as CharacterBody2D
	
	if not character_body:
		push_error("\"character_body\" was not assigned and parent is not "
			+ "CharacterBody2D. Disabling controller.")
		movement_enabled = false


func _physics_process(_delta):
	if not movement_enabled:
		return
	character_body.move_and_slide()


## Moves the character by [param speed] amount in the current [member direction].
## If [param new_direction] is not [code]Vector2.ZERO[/code] will update
## [member direction] before moving.
func move(speed: float = movement_speed, new_direction: Vector2 = Vector2.ZERO):
	if not movement_enabled:
		return
	if not character_body:
		push_error("\"character_body\" is not assigned.")
		return
	
	if new_direction:
		direction = new_direction
	
	if not speed or not direction:
		return
	
	character_body.velocity = direction * speed
	is_moving = true
	
	moved.emit(direction, speed)


## Resets the [member character_body]'s [member CharacterBody2D.velocity].
func stop():
	if character_body:
		character_body.velocity = Vector2.ZERO
	is_moving = false


## Updates [member character_body]'s [member CharacterBody2D.global_position].
func teleport(new_position: Vector2):
	if not character_body:
		push_error("\"character_body\" is not assigned.")
		return
	
	var old_position := character_body.global_position
	
	character_body.global_position = new_position
	teleported.emit(new_position, old_position)
