@icon("player.png")
class_name Player
extends Node

signal character_changed(new_character: Character2D, old_character: Character2D)

@export var bullet_types: Array[Resource] 
@export var character: Character2D:
	set(value):
		if value == character:
			return
		
		var old_character = character
		character = value
		
		character_changed.emit(character, old_character)

@onready var shoot_controller: ShootController = $ShootController
@onready var hurt_component: HurtComponent = $HurtComponent
@onready var controller: MovementController2D = $Controller
@onready var interactor: Interactor = $Interactor
@onready var trigger: Area2D = $Center
@onready var room: Area2D = $Room
@onready var camera: GridCamera2D = %Camera
@onready var camera_controller: GridCameraFollower2D = $Camera/BehaviorFollow
@onready var camera_transitioner: GridCameraTransitionFade = $Camera/TransitionFade
@onready var health_ui: HealthUI = $UI/HealthUI


func _ready():
	_on_character_changed(character, null)
	health_ui.update_health(hurt_component.current_health, hurt_component.max_health)


func _process(_delta: float):
	_update_component_positions()


func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("shoot"):
		shoot_controller.direction = interactor.direction
		shoot_controller.create_a_projectile_from_argument(bullet_types[0])


## Some components like [member interactor] are expected to be children to the
## [member character] directily. This func syncs their positions with the
## [member character] to avoid that.
func _update_component_positions():
	if not character:
		return
	
	interactor.global_position = character.global_position
	trigger.global_position = character.global_position
	hurt_component.global_position = character.global_position
	shoot_controller.global_position = character.global_position


func _on_character_changed(new_character: Character2D, old_character: Character2D):
	if old_character:
		old_character.movement = null
		old_character.interactor = null
		old_character.shoot_controller = null
		old_character.hurt_component = null
	if new_character:
		new_character.movement = controller
		new_character.interactor = interactor
		new_character.shoot_controller = shoot_controller
		new_character.hurt_component = hurt_component
		
	if camera_controller:
		camera_controller.target = new_character


func _on_health_changed(_amount: float = 0.0):
	if hurt_component:
		health_ui.update_health(hurt_component.current_health, hurt_component.max_health)


func _on_fatal_damage_taken():
	get_tree().reload_current_scene.call_deferred()


func _on_camera_cell_changed(new_cell: Vector2, _smooth_transition: bool) -> void:
	if room:
		room.global_position = Vector2(320, 160) * new_cell
