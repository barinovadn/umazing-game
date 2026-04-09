@icon("player.png")
class_name Player
extends Node

signal character_changed(new_character: Character2D, old_character: Character2D)

@export var character: Character2D:
	set(value):
		if value == character:
			return
		
		var old_character = character
		character = value
		
		character_changed.emit(character, old_character)

@onready var player_fight_controller: ShootController2D = $PlayerFightController
@onready var hurt_component: HurtComponent = $HurtComponent
@onready var controller: MovementController2D = $Controller
@onready var interactor: Interactor = $Interactor
@onready var trigger: Node2D = $Trigger
@onready var camera: GridCamera2D = %Camera
@onready var camera_controller: GridCameraFollower2D = $Camera/BehaviorFollow
@onready var camera_transitioner: GridCameraTransitionFade = $Camera/TransitionFade
@onready var timer: Timer = $Timer
@onready var health_ui: HealthUI = $UI/HealthUI

var is_shooting : bool = false:
	set(value):
		if value != is_shooting:
			is_shooting = value
			player_fight_controller.is_shooting = value
@export var bullet_types: Array[Resource] 

func _ready():
	_on_character_changed(character, null)
	hurt_component.damaged.connect(update_current_health)
	update_current_health()

func _process(_delta: float):
	hurt_component.global_position = character.global_position
	_update_component_positions()

## Some components like [member interactor] are expected to be children to the
## [member character] directily. This func syncs their positions with the
## [member character] to avoid that.
func _update_component_positions():
	if not character:
		return
	
	interactor.global_position = character.global_position
	trigger.global_position = character.global_position

func _on_character_changed(new_character: Character2D, old_character: Character2D):
	if old_character:
		old_character.movement = null
		old_character.interactor = null
		old_character.shoot_controller = null
		old_character.hurt_component = null
	if new_character:
		new_character.movement = controller
		new_character.interactor = interactor
		new_character.shoot_controller = player_fight_controller
		new_character.hurt_component = hurt_component
	if player_fight_controller:
		player_fight_controller.character_body = new_character
		

	if camera_controller:
		camera_controller.target = new_character

func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("shoot") && !is_shooting:
		is_shooting = true
		player_fight_controller.direction = interactor.direction
		player_fight_controller.create_a_projectile_from_argument(bullet_types[0])
		timer.start()

func _on_timer_timeout() -> void:
	is_shooting = false

func update_current_health():
	health_ui.update_health(hurt_component.current_health, hurt_component.health)
