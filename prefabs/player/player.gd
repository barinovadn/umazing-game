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

@onready var player_fight_controller: ShootController2D = %ShootComponent
@onready var hurt_component: HurtComponent = %HurtComponent
@onready var controller: MovementController2D = $Controller
@onready var interactor: Interactor = %Interactor
@onready var trigger: Node2D = $CharacterPosition/Trigger
@onready var pickup_area: Node2D = $CharacterPosition/PickUp
@onready var camera: GridCamera2D = %Camera
@onready var camera_controller: GridCameraFollower2D = $Camera/BehaviorFollow
@onready var camera_transitioner: GridCameraTransitionFade = $Camera/TransitionFade
@onready var inventory: Inventory = $UI/Inventory
@onready var combat_ui: HealthUI = $UI/CombatUI
@onready var timer: Timer = $Timer
@onready var timer_for_dash: Timer = $TimerForDash
@onready var sound_player: SoundPlayer = $SoundPlayer

var can_dash: bool = true
var is_shooting : bool = false:
	set(value):
		if value != is_shooting:
			is_shooting = value
			player_fight_controller.is_shooting = value


func _ready():
	_on_character_changed(character, null)
	## TODO Move to inventory (isolate logic)
	if inventory:
		inventory.hide()
	hurt_component.damaged.connect(on_damaged)
	hurt_component.fatal_damage_taken.connect(on_fatal_damage_taken)
	combat_ui.update_health(hurt_component.current_health, hurt_component.max_health)


func _process(_delta: float):
	_update_component_positions()

## Some components like [member interactor] are expected to be children to the
## [member character] directily. This func syncs their positions with the
## [member character] to avoid that.
func _update_component_positions():
	if not character:
		return
	
	$CharacterPosition.global_position = character.global_position
	
	#interactor.global_position = character.global_position
	#trigger.global_position = character.global_position
	#pickup_area.global_position = character.global_position


## TODO Move to inventory (isolate logic)
func _input(event):
	if event.is_action_pressed("inventory"): 
		inventory.visible = !inventory.visible
		
		if inventory.visible:
			inventory.grab_focus() 
		else:
			inventory.action_panel.hide()
	elif Input.is_action_pressed("shoot") && !is_shooting:
		is_shooting = true
		player_fight_controller.direction = interactor.direction
		player_fight_controller.create_a_projectile_from_argument(bullet_types[0])
		timer.start()
	
	hurt_component.global_position = character.global_position
	player_fight_controller.global_position = character.global_position


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
		
	if camera_controller:
		camera_controller.target = new_character


## A timer that tracks the time elapsed since the previous shot;
## once the time has elapsed, it will allow you to shoot again
func _on_timer_timeout() -> void:
	is_shooting = false

## Plays random hit sound and updates health
func on_damaged():
	sound_player.play_random_hit_sound()
	combat_ui.update_health(hurt_component.current_health, hurt_component.max_health)

## Is called when player lost all his hp
func on_fatal_damage_taken():
	call_deferred("_reload_scene")

## Reload curent scene
func _reload_scene():
	get_tree().reload_current_scene()
