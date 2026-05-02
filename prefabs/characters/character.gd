@icon("character.png")
class_name Character2D
extends CharacterBody2D
## Base class for all characters, both playable and NPCs.

signal destroyed
signal deleted
signal hurt_component_changed(new_component)
signal shoot_controller_changed(new_controller)

@export_group("Animations")
@export var animator: AnimationController2D
@export var start_animation := AnimationController2D.AnimationType.NONE

@export_group("Movement")
@export var movement: MovementController2D:
	set(value):
		if movement:
			movement.moved.disconnect(_on_moved)
			movement.teleported.disconnect(_on_teleported)
			movement.movement_stopped.disconnect(_on_movement_stopped)
			movement.direction_changed.disconnect(_on_direction_changed)
		
		movement = value
		
		if movement:
			movement.moved.connect(_on_moved)
			movement.teleported.connect(_on_teleported)
			movement.movement_stopped.connect(_on_movement_stopped)
			movement.direction_changed.connect(_on_direction_changed)

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

@export_group("Combat")
@export var hurt_component: HurtComponent:
	set(value):
		if hurt_component:
			hurt_component.fatal_damage_taken.disconnect(_on_died)
		hurt_component = value
		hurt_component_changed.emit(hurt_component)
		if hurt_component:
			hurt_component.fatal_damage_taken.connect(_on_died)
@export var shoot_controller: ShootController:
	set(value): 
		if shoot_controller:
			shoot_controller.shooting_started.disconnect(_on_shooting_started)
			shoot_controller.shooting_stopped.disconnect(_on_shooting_stopped)
		shoot_controller = value
		shoot_controller_changed.emit(shoot_controller)
		if shoot_controller:
			shoot_controller.shooting_started.connect(_on_shooting_started)
			shoot_controller.shooting_stopped.connect(_on_shooting_stopped)

@export_group("Afterlife")
@export var afterlife_time: float = 7.0
@export var afterlife_fade_time: float = 2.0

var is_moving: bool: ## NOTE Read-only.
	get(): return movement.is_moving if movement else false
var direction: Vector2: ## NOTE Read-only.
	get(): return movement.direction if movement else Vector2.DOWN
var is_shooting: bool: ## NOTE Read-only.
	get(): return shoot_controller.is_shooting if shoot_controller else false
var is_deleted_with_delay: bool = false

func _ready():
	if animator:
		animator.play(start_animation)

func _physics_process(_delta):
	if is_moving:
		move_and_slide()

func _update_animation():
	if not animator:
		return
	if is_deleted_with_delay:
		if not animator.play(animator.AnimationType.DOWNED):
			visible = false
	elif is_shooting:
		animator.play_attack(direction)
	elif is_moving:
		animator.play_walk(direction)
	else:
		animator.play_idle(direction)

## Turns off the collision visibility layer and deletes the object after 5 seconds
func _on_died():
	destroy()

## If there is a sound effect when removing a bullet, play it.
## The bullet will be removed after the last sound effect ends.
func _delete():
	queue_free()
	deleted.emit()

func _on_moved(dir: Vector2, speed: float):
	velocity = dir * speed
	_update_animation()

func _on_teleported(new_position: Vector2):
	global_position = new_position

func _on_movement_stopped():
	velocity = Vector2.ZERO
	_update_animation()

func _on_direction_changed(new_dir: Vector2):
	if interactor:
		interactor.direction = new_dir
	_update_animation()

func _on_shooting_started():
	_update_animation()

func _on_shooting_stopped():
	_update_animation()

func destroy():
	is_deleted_with_delay = true
	collision_layer = 0
	destroyed.emit()
	
	_update_animation()
	
	if afterlife_time > 0:
		var timer = get_tree().create_timer(afterlife_time - afterlife_fade_time)
		await timer.timeout
		
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, afterlife_fade_time)
		await tween.finished
	
	_delete()
