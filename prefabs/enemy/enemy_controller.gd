extends Area2D
class_name EnemyController

@export var character: Character2D

@export_group("Combat")
## An array containing all types of projectiles used by the boss
@export var bullet_types: Array[Resource]
@export var boss_actions: Array[Action]

## The array stores the HP percentage values (in the range of 0 to 1) at which the
## boss advances to the next phase. You need to record the HP percentage
## for each phase, starting with the second one. 
@export var modulates_for_phase: Array[float]

@export var movement_patterns: Dictionary[String, MovementController2D]

@export_group("Controllers")
@export var shoot_controller: ShootController
@export var hurt_controller: HurtController

@export_group("Teleports")
@export var teleport_in : Teleport
@export var teleport_out: Teleport

@export_group("Interface")
@export var enemy_name: String
@export var data_for_interface: BossUIData
@export var BossInterface: BossUI

## A timer that sets the interval between actions
@onready var action_changer: Timer = $ActionChanger
## Sets the interval between shots for a specific type of attack
@onready var pause_between_shots: Timer = $PauseBetweenShots

## Current boss movement pattern
var current_movement: MovementController2D
var current_bullet_type : Resource
var current_phase: int = 1

func _enemy_ready(): pass

func _ready() -> void:
	if not character:
		character = get_parent() as Character2D
	character.deleted.connect(_set_portals)
	BossInterface = %Player/%BossUI
	hurt_controller.health_changed.connect(on_health_changed)
	hurt_controller.fatal_damage_taken.connect(on_fatal_damage_taken)
	_enemy_ready()

## Overridable logic for each boss;
## this is where the specific actions and procedures for each action are defined
func _use_brain(_action: Action):
	pass

## Sets up portals associated with the boss. Disables the entrance portal,
## spawns an exit portal at the boss's death location, and activates it.
func _set_portals():
	deactivate_portale(teleport_in)
	activate_portal(teleport_out)
	teleport_out.global_position = hurt_controller.global_position

## Replaces the boss's action and plays it
func _on_action_changer_timeout() -> void:
	pause_between_shots.stop()
	var ready_boss_actions: Array[Action] = _select_available_actions()
	var action_to_play: Action = _select_action_by_weight(ready_boss_actions)
	_use_brain(action_to_play)

func _on_pause_between_shots_timeout() -> void:
	shoot_controller.create_a_projectile_from_argument(current_bullet_type)

## Selects actions from the boss's set of available actions that are available in this phase
func _select_available_actions() -> Array[Action]:
	var ready_boss_actions: Array[Action]
	
	for action in boss_actions:
		if current_phase in action.phases:
			ready_boss_actions.append(action)
	
	return ready_boss_actions

## Selects an action available in this phase
func _select_action_by_weight(ready_boss_actions: Array[Action]) -> Action:
	var chance_of_action: float = randf()
	
	var action_to_play: Action = null
	
	if ready_boss_actions.size() == 1:
		return ready_boss_actions[0]

	for action in ready_boss_actions:
		if chance_of_action <= action.weight:
			if !action_to_play or action.weight<= action_to_play.weight:
				action_to_play = action
	
	if !action_to_play:
		return ready_boss_actions.pick_random()
	
	return action_to_play

## Checks whether a phase change is necessary and, if the conditions are met, increases it
func _check_phase():
	if (current_phase < modulates_for_phase.size() + 1):
		var hp_for_phase_change: float = hurt_controller.max_health * modulates_for_phase[current_phase-1]
		if (hurt_controller.current_health <= hp_for_phase_change):
			current_phase+=1
			var available_actions = _select_available_actions()
			var heaviest_action = _find_heaviest_action(available_actions)
			_rebalance_weights(available_actions, 1.0/heaviest_action.weight)

func _find_heaviest_action(array: Array[Action]):
	if !array:
		return
	var action: Action = array[0]
	for element in array: 
		if action.weight < element.weight:
			action = element
			
	return action

func _rebalance_weights(array: Array[Action], rebalance_koef: float):
	for element in array: 
		element.weight *= rebalance_koef

func on_health_changed(_amount: float):
	BossInterface.update_health(enemy_name, hurt_controller.current_health)
	_check_phase()

func on_fatal_damage_taken():
	deactivate_interaction()
	
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	
	BossInterface.remove_boss(enemy_name)

## Allows the boss to move, shoot, and select an action
func activate_interaction():
	_on_action_changer_timeout()
	action_changer.start()
	current_movement.movement_enabled = true
	shoot_controller.can_shoot = true

## Prevents the boss from moving or shooting and selects an action
func deactivate_interaction():
	action_changer.stop()
	current_movement.movement_enabled = false
	shoot_controller.can_shoot = false

func deactivate_portale(portal : Teleport):
	portal.enabled = false

func activate_portal(portal: Teleport):
	portal.enabled = true
