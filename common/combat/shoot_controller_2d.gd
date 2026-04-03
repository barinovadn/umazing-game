@icon("boxer_gloves.png")
class_name ShootController2D
extends Node

signal shooting_started()
signal shooting_stopped()

@export var bullet_types: Array[Resource] 
@export var character_body: CharacterBody2D
@export var fighting_enabled: bool = true:
	set(value):
		if fighting_enabled != value:
			fighting_enabled = value


var projectile : Bullet
var direction : Vector2
var is_shooting : bool = false:
	set(value):
		if value == is_shooting:
			return
		elif is_shooting && !fighting_enabled:
			return
		is_shooting = value
		if is_shooting:
			shooting_started.emit()
		else:
			shooting_stopped.emit()

func _ready():
	if not character_body:
		character_body = get_parent().character as CharacterBody2D
	
	if not character_body:
		push_error("\"character_body\" was not assigned and parent is not "
			+ "CharacterBody2D. Disabling controller.")
		fighting_enabled = false

func create_a_projectile() -> void:
	if !fighting_enabled:
		return
	
	projectile = bullet_types.pick_random().instantiate() as Bullet
	
	projectile.direction_needed.connect(on_direction_needed)
	
	projectile.global_position = character_body.global_position
	get_tree().root.add_child(projectile)

func create_a_projectile_from_argument(bullet: Resource) -> void:
	if !fighting_enabled:
		return
	
	projectile = bullet.instantiate() as Bullet
	
	projectile.direction_needed.connect(on_direction_needed)
	
	projectile.global_position = character_body.global_position
	get_tree().root.add_child(projectile)

func on_direction_needed():
	if !direction:
		print("No direction for shooting system")
	projectile.direction = direction
