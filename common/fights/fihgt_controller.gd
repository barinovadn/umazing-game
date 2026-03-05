class_name FightController2D
extends Node
## Base fighting controller for a character. Manages shooting state and direction.

## Emitted when fighting mode is activated (e.g., shooting starts).
signal fighting_started()
## Emitted when fighting mode is deactivated (e.g., shooting stops).
signal fighting_stopped()
## Emitted when shooting starts.
signal shooting_started()
## Emitted when shooting stops.
signal shooting_stopped()
## Emitted when [member direction] changes.
signal direction_changed(direction: Vector2)
## Emitted when [member fighting_enabled] changes.
signal fighting_toggled(enabled: bool)

## The [CharacterBody2D] node this controller operates on.
## If not assigned, the parent node will be used.
@export var character_body: CharacterBody2D

@export_group("Fight", "fight")
## Speed of projectiles (or movement when shooting) in pixels per second.
@export var bullet_speed: float = 200.0
## If [code]false[/code], fighting is disabled and [method stop] is called.
@export var fighting_enabled: bool = true:
	set(value):
		if fighting_enabled != value:
			fighting_enabled = value
			fighting_toggled.emit(value)
			
			if not fighting_enabled:
				stop()

@export_group("Movement")
## Reference to a [MovementController2D] used to obtain the current direction.
@export var movement: MovementController2D

## Current fighting direction (read‑only). Obtained from the [member movement] controller.
var direction: Vector2: ## NOTE Read‑only.
	get(): return movement.direction if movement else Vector2.DOWN

## Whether the character is currently shooting.
var is_shooting: bool = false:
	set(value):
		if value == is_shooting:
			return
		
		is_shooting = value
		if is_shooting:
			shooting_started.emit()
		else:
			shooting_stopped.emit()


func _ready():
	if not character_body:
		character_body = get_parent() as CharacterBody2D
	
	if not character_body:
		push_error("\"character_body\" was not assigned and parent is not "
			+ "CharacterBody2D. Disabling controller.")
		fighting_enabled = false


func _physics_process(_delta):
	if not fighting_enabled:
		return
	character_body.move_and_slide()


## Moves the character by setting its velocity based on [param speed] and the current direction.
## If [param new_direction] is provided (non‑zero), it updates [member direction] before moving.
func move(speed: float = bullet_speed, new_direction: Vector2 = Vector2.ZERO):
	if not fighting_enabled:
		return
	if not character_body:
		push_error("\"character_body\" is not assigned.")
		return
	
	if new_direction:
		direction = new_direction
	
	if not speed or not direction:
		return
	
	character_body.velocity = direction * speed
	is_shooting = true


## Stops the character by zeroing its velocity and ends the shooting state.
func stop():
	if character_body:
		character_body.velocity = Vector2.ZERO
	is_shooting = false
