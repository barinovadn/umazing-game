@icon("character.png")
class_name Character2D
extends CharacterBody2D
## Base class for all characters, both playable and NPCs.


@export_group("Animations")
@export var animator: AnimationController2D
@export var start_animation := AnimationController2D.AnimationType.NONE

@export_group("Movement")
@export var movement: MovementController2D:
	set(value):
		if movement:
			movement.moved.disconnect(_on_moved)
			movement.movement_stopped.disconnect(_on_movement_stopped)
			movement.direction_changed.disconnect(_on_direction_changed)
		
		movement = value
		
		if movement:
			movement.moved.connect(_on_moved)
			movement.movement_stopped.connect(_on_movement_stopped)
			movement.direction_changed.connect(_on_direction_changed)
var is_moving: bool: ## NOTE Read-only.
	get(): return movement.is_moving if movement else false
var direction: Vector2: ## NOTE Read-only.
	get(): return movement.direction if movement else Vector2.DOWN

@export_group("Collision")
@export var collider: CollisionShape2D:
	set(value):
		collider = value
		if not collider:
			return
		collision = collision
@export var collision: bool = true:
	set(value):
		if not collider:
			return
		collider.disabled = not value
	get():
		if not collider:
			return false
		return not collider.disabled

@export_group("Interactions")
@export var interactor: Interactor


func _ready():
	if animator:
		animator.play(start_animation)


func _physics_process(_delta):
	if is_moving:
		move_and_slide()


func _update_animation():
	if not animator:
		return
	
	if is_moving:
		animator.play_walk(direction)
	else:
		animator.play_idle(direction)


func _on_moved(dir: Vector2, speed: float):
	velocity = dir * speed
	_update_animation()


func _on_movement_stopped():
	velocity = Vector2.ZERO
	_update_animation()


func _on_direction_changed(new_dir: Vector2):
	if interactor:
		interactor.direction = new_dir
	_update_animation()
