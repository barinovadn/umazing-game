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


func _use_brain(_action: Action):
	pass
	
func activate_interaction():
	_use_brain(boss_actions.pick_random())
	action_changer.start()
	current_movement.movement_enabled = true
	shoot_controller_2d.fighting_enabled = true


func deactivate_interaction():
	action_changer.stop()
	current_movement.movement_enabled = false
	shoot_controller_2d.fighting_enabled = false


func deactivate_portale(portal : Teleport):
	portal.set_deferred("monitorable", false)
	portal.set_deferred("monitoring", false)
	
func activate_portal(portal: Teleport):
	portal.set_deferred("monitorable", true)
	portal.set_deferred("monitoring", true)

func _on_action_changer_timeout() -> void:
	pause_between_shots.stop()
	_use_brain(boss_actions.pick_random())


func _on_pause_between_shots_timeout() -> void:
	shoot_controller_2d.create_a_projectile_from_argument(current_bullet_type)
