extends Area2D

class_name EnemyController

@export var bullet_types: Array[Resource]
@export var boss_actions: Array[Action]
@export var movement_patterns: Dictionary[String, MovementController2D]

@onready var action_changer: Timer = $ActionChanger
@onready var pause_between_shots: Timer = $PauseBetweenShots
@export var shoot_controller_2d: ShootController2D
@export var hurt_controller: HurtComponent
@export var teleport_in : Teleport
@export var teleport_out: Teleport

var current_movement: MovementController2D
var current_bullet_type : Resource
var current_phase: int


func activate_interaction():
	current_phase = 1
	_on_action_changer_timeout()
	action_changer.start()
	current_movement.movement_enabled = true
	shoot_controller_2d.fighting_enabled = true


func deactivate_interaction():
	action_changer.stop()
	current_movement.movement_enabled = false
	shoot_controller_2d.fighting_enabled = false


func deactivate_portale(portal : Teleport):
	portal.enabled = false
	
func activate_portal(portal: Teleport):
	portal.enabled = true


func _use_brain(_action: Action):
	pass


func _set_portals():
	deactivate_portale(teleport_in)
	activate_portal(teleport_out)
	teleport_out.global_position = hurt_controller.global_position
	

func _on_action_changer_timeout() -> void:
	pause_between_shots.stop()
	
	var chance_of_action: float = randf()
	var ready_boss_actions: Array[Action]
	
	for action in boss_actions:
		if current_phase in action.phases:
			ready_boss_actions.append(action)

	var action_to_play: Action = null
	
	if ready_boss_actions.size() == 1:
		_use_brain(ready_boss_actions[0])
		return

	for action in ready_boss_actions:
		if chance_of_action <= action.weight:
			if !action_to_play or action.weight<= action_to_play.weight:
				action_to_play = action

	if !action_to_play:
		_use_brain(ready_boss_actions.pick_random())
	else:
		_use_brain(action_to_play)

func _on_pause_between_shots_timeout() -> void:
	shoot_controller_2d.create_a_projectile_from_argument(current_bullet_type)
