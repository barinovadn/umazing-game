@icon("character.png")
class_name Character2D
extends CharacterBody2D
## Base class for all characters, both playable and NPCs.

signal destroyed
signal deleted
signal hurt_component_changed(new_component: HurtComponent)
signal shoot_controller_changed(new_controller: ShootController)
signal movement_controller_changed(new_controller: MovementController2D)

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
		movement_controller_changed.emit(movement)
		
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
		collider.set_deferred("disabled", not value)
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
			shoot_controller.post_shot_cd_started.disconnect(_on_shooting_started)
			shoot_controller.post_shot_cd_finished.disconnect(_on_shooting_stopped)
		
		shoot_controller = value
		shoot_controller_changed.emit(shoot_controller)
		
		if shoot_controller:
			shoot_controller.post_shot_cd_started.connect(_on_shooting_started)
			shoot_controller.post_shot_cd_finished.connect(_on_shooting_stopped)

@export_group("Afterlife", "afterlife")
@export var afterlife_duration: float = 7.0
@export var afterlife_fade_out_duration: float = 2.0

@export_group("Stats", "stat")
@export var stat_speed_ratio: Stat
@export var stat_invincibility: Stat
@export var stat_armor: Stat
@export var stat_health_ratio: Stat

var direction: Vector2:
	set(value):
		direction = value
		_update_animation()
		if interactor:
			interactor.direction = direction
	get():
		if direction:
			return direction
		if movement:
			return movement.direction
		return Vector2.DOWN
var is_moving: bool: ## NOTE Read-only.
	get(): return movement.is_moving if movement else false
var is_shooting: bool: ## NOTE Read-only.
	get(): return shoot_controller.is_animation_needed if shoot_controller else false
var is_deleted: bool = false


func _ready():
	if animator:
		animator.play(start_animation)
	if movement:
		movement.direction = Vector2.DOWN


func _physics_process(_delta):
	if is_moving:
		move_and_slide()


func _update_animation():
	if not animator:
		return
	if is_deleted:
		if animator.has_animation(animator.AnimationType.DOWNED):
			animator.play(animator.AnimationType.DOWNED)
		else:
			visible = false
	elif is_shooting:
		animator.play_attack(direction)
	elif is_moving:
		animator.play_walk(direction)
	else:
		animator.play_idle(direction)


func _on_died():
	destroy()


func _on_moved(dir: Vector2, speed: float):
	velocity = dir * speed * (
		stat_speed_ratio.value if stat_speed_ratio
		else 1.0)
	
	_update_animation()


func _on_teleported(new_position: Vector2):
	global_position = new_position


func _on_movement_stopped():
	velocity = Vector2.ZERO
	_update_animation()


func _on_direction_changed(_new_dir: Vector2):
	if interactor:
		interactor.direction = direction
	if shoot_controller:
		shoot_controller.direction = direction
	_update_animation()


func _on_shooting_started():
	_update_animation()


func _on_shooting_stopped():
	_update_animation()


func destroy():
	is_deleted = true
	collision_layer = 0
	destroyed.emit()
	
	_update_animation()
	
	if afterlife_duration > 0:
		var timer = get_tree().create_timer(afterlife_duration - afterlife_fade_out_duration)
		await timer.timeout
		
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, afterlife_fade_out_duration)
		await tween.finished
	
	delete()


func delete():
	queue_free()
	deleted.emit()
