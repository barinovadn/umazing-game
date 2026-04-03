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

@export_group("Dialogue")
@export var say_on_start: bool = false
@export var start_phrase: String = "Ну что, начнём приключение!"
@export var dialogue_preset: String = "npc"
@export var dialogue_name: String = ""
@export var portrait_texture: Texture2D = preload("res://prefabs/characters/portrait.png")
@export var bubble_target_path: NodePath


func _ready():
	if animator:
		animator.play(start_animation)

	if say_on_start:
		_say_start_phrase()


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


func _on_teleported(new_position: Vector2):
	global_position = new_position


func _on_movement_stopped():
	velocity = Vector2.ZERO
	_update_animation()


func _on_direction_changed(new_dir: Vector2):
	if interactor:
		interactor.direction = new_dir
	_update_animation()


func _say_start_phrase() -> void:
	await get_tree().process_frame

	var ds = get_tree().get_first_node_in_group("dialogue_system")
	if ds == null:
		var nodes := get_tree().get_nodes_in_group("dialogue_system")
		if nodes.size() > 0:
			ds = nodes[0]

	if ds == null:
		return

	var target: CanvasItem = self
	if bubble_target_path != NodePath():
		var n := get_node_or_null(bubble_target_path)
		if n is CanvasItem:
			target = n

	ds.say(target, start_phrase, 2.5, dialogue_preset)
