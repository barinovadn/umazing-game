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
			movement.teleported.disconnect(_on_teleported)
			movement.movement_stopped.disconnect(_on_movement_stopped)
			movement.direction_changed.disconnect(_on_direction_changed)
		
		movement = value
		
		if movement:
			movement.moved.connect(_on_moved)
			movement.teleported.connect(_on_teleported)
			movement.movement_stopped.connect(_on_movement_stopped)
			movement.direction_changed.connect(_on_direction_changed)
@export var velocity_koef: float = 1
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

@export_group("Fight")
@export var hurt_component: HurtComponent:
	set(value):
		if hurt_component:
			hurt_component.fatal_damage_taken.disconnect(_on_died)
		hurt_component = value
		if hurt_component:
			hurt_component.fatal_damage_taken.connect(_on_died)
@export var shoot_controller: ShootController2D:
	set(value): 
		if shoot_controller:
			shoot_controller.shooting_started.disconnect(_on_shooting_started)
			shoot_controller.shooting_stopped.disconnect(_on_shooting_stopped)
		shoot_controller = value
		if shoot_controller:
			shoot_controller.shooting_started.connect(_on_shooting_started)
			shoot_controller.shooting_stopped.connect(_on_shooting_stopped)
var is_shooting: bool: ## NOTE Read-only.
	get(): return shoot_controller.is_shooting if shoot_controller else false


func _ready():
	if animator:
		animator.play(start_animation)


func _physics_process(_delta):
	if is_moving:
		move_and_slide()


func _update_animation():
	if not animator:
		return
	
	if is_shooting:
		animator.play_attack(direction)
	elif is_moving:
		animator.play_walk(direction)
	else:
		animator.play_idle(direction)

func _on_died():
	queue_free()
	#get_tree().reload_current_scene()


func _on_moved(dir: Vector2, speed: float):
	velocity = dir * speed * velocity_koef
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
