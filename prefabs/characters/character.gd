@icon("character.png")
class_name Character2D
extends CharacterBody2D
## Base class for all characters, both playable and NPCs.


@export_group("Animations")
@export var animator: AnimationController2D
@export var start_animation := AnimationController2D.AnimationType.NONE

@export_group("Movement")
@export var movement: MovementController2D
var is_moving: bool: ## NOTE Read-only.
	get(): return movement.is_moving if movement else false
var direction: Vector2: ## NOTE Read-only.
	get(): return movement.direction if movement else Vector2.DOWN

@export_group("Collision")
@export var collider: CollisionShape2D
@export var collision: bool = true:
	set(value):
		if not collider:
			return
		collider.disabled = not value
	get():
		if not collider:
			return false
		return not collider.disabled


func _ready():
	if animator:
		animator.play(start_animation)
	else:
		push_error("\"animator\" component is not defined.")
	
	if collider:
		collision = collision
	else:
		push_error("\"collider\" is not defined.")
	
	if movement:
		movement.moved.connect(_on_moved)
		movement.movement_stopped.connect(_on_movement_stopped)
		movement.direction_changed.connect(_on_direction_changed)


func _update_animation():
	if not animator:
		return
	
	if is_moving:
		animator.play_walk(direction)
	else:
		animator.play_idle(direction)


func _on_moved(_direction: Vector2, _speed: float):
	_update_animation()


func _on_movement_stopped():
	_update_animation()


func _on_direction_changed(_direction: Vector2):
	_update_animation()
