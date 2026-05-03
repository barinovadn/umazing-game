@icon("enemy_controller.png")
extends Area2D
class_name EnemyController


@export var character: Character2D

@export_group("Combat")
@export var rest_duration: float
@export_range(0.0, 1.0) var chance_of_rest: float
## An array containing all types of projectiles used by the boss
@export var bullet_types: Array[Resource]
@export var actions: Array[Action]
## Stores the HP percentage values (in the range of 0 to 1) at which the
## boss advances to the next phase. You need to record the HP percentage
## for each phase, starting with the second one. 
@export var modulates_for_phase: Array[float]
@export var movement_patterns: Dictionary[String, MovementController2D]

@export_group("Event Responses")
@export var show_on_activation: Array[Node2D]
@export var hide_on_activation: Array[Node2D]
@export var show_on_death: Array[Node2D]
@export var hide_on_death: Array[Node2D]
@export var tp_on_death: Node2D

@export_group("Interface")
@export var display_name: String
@export var data_for_interface: TexturesUI
## Allows you to specify the [BossUI] location where the interface will be added.
## By default, it is displayed in the player's [BossUI].
@export var display_location: BossUI

## A timer that sets the interval between actions
@onready var action_changer: Timer = $ActionChanger
## Sets the interval between shots for a specific type of attack
@onready var pause_between_shots: Timer = $PauseBetweenShots

## Current boss movement pattern
var current_movement: MovementController2D
var current_bullet_type: Resource
var current_phase: int = 1

var hurt_component: HurtComponent
var shoot_controller: ShootController

func _enemy_ready(): pass

func _ready():
	if not character:
		character = get_parent() as Character2D
	character.deleted.connect(_set_target_point)
	display_location = %Player/%BossUI
	
	character.hurt_component_changed.connect(attach_hurt_component)
	character.shoot_controller_changed.connect(attach_shoot_controller)
	
	hurt_component = character.hurt_component
	shoot_controller = character.shoot_controller
	
	hurt_component.health_changed.connect(_on_health_changed)
	hurt_component.fatal_damage_taken.connect(_on_fatal_damage_taken)
	_enemy_ready()

## Overridable logic for each boss;
## this is where the specific actions and procedures for each action are defined
func _use_brain(_action: Action):
	pass

## Sets up portals associated with the boss. Disables the entrance portal,
## spawns an exit portal at the boss's death location, and activates it.
func _set_target_point():
	if tp_on_death:
		tp_on_death.global_position = hurt_component.global_position
	
	activate_points(show_on_death)
	deactivate_points(hide_on_death)

## Replaces the boss's action and plays it
func _on_action_changer_timeout():
	action_changer.stop()
	pause_between_shots.stop()
	
	var ready_boss_actions: Array[Action] = _select_available_actions()
	var action_to_play: Action = _select_action_by_weight(ready_boss_actions)
	
	action_changer.wait_time = action_to_play.duration
	action_changer.start()
	_use_brain(action_to_play)


func _on_pause_between_shots_timeout():
	shoot_controller.create_a_projectile_from_argument(current_bullet_type)

## Selects actions from the boss's set of available actions that are available in this phase
func _select_available_actions() -> Array[Action]:
	var ready_boss_actions: Array[Action]
	
	for action in actions:
		if current_phase in action.phases:
			ready_boss_actions.append(action)
	
	return ready_boss_actions

## Selects an action available in this phase
func _select_action_by_weight(ready_boss_actions: Array[Action]) -> Action:
	var array_length: float = 0.0
	
	for action in ready_boss_actions:
		array_length += action.weight
	
	var chance_of_action: float = randf_range(0, array_length)
	
	var current_length: float = 0.0
	var action_to_play: Action
	
	for action in ready_boss_actions:
		current_length += action.weight
		if chance_of_action <= current_length:
			action_to_play = action
			break
	
	if !action_to_play:
		return ready_boss_actions.pick_random()
	
	return action_to_play

## Checks whether a phase change is necessary and, if the conditions are met, increases it
func _check_phase():
	if (current_phase < modulates_for_phase.size() + 1):
		var hp_for_phase_change: float = hurt_component.max_health * modulates_for_phase[current_phase-1]
		if (hurt_component.current_health <= hp_for_phase_change):
			current_phase+=1


func _on_health_changed(_amount: float):
	display_location.update_health(display_name, hurt_component.current_health)
	_check_phase()


func _on_fatal_damage_taken():
	deactivate_interaction()
	
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	
	display_location.remove_boss(display_name)

## Allows the boss to move, shoot, and select an action
func activate_interaction(_area: Area2D = null):
	activate_points(show_on_activation)
	deactivate_points(hide_on_activation)
	
	_on_action_changer_timeout()
	action_changer.start()
	current_movement.movement_enabled = true
	shoot_controller.can_shoot = true

## Prevents the boss from moving or shooting and selects an action
func deactivate_interaction(_area: Area2D = null):
	action_changer.stop()
	current_movement.movement_enabled = false
	shoot_controller.can_shoot = false


func deactivate_points(points: Array[Node2D]):
	for point in points:
		point.visible = false
		point.process_mode = Node.PROCESS_MODE_DISABLED


func activate_points(points: Array[Node2D]):
	for point in points:
		point.visible = true
		point.process_mode = Node.PROCESS_MODE_INHERIT


func attach_hurt_component(component: HurtComponent):
	hurt_component = component


func attach_shoot_controller(controller: ShootController):
	shoot_controller = controller
