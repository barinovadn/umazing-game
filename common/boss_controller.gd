extends Node2D

class_name BossController

@export var bullet_types: Array[Resource]
@export var boss_actions: Array[Action]

@onready var action_changer: Timer = $ActionChanger
@onready var pause_between_shots: Timer = $PauseBetweenShots
@export var shoot_controller_2d: ShootController2D
@export var hurt_controller: HurtComponent

var current_bullet_type : Resource

func _use_brain(action: Action):
	pass

func _on_action_changer_timeout() -> void:
	pause_between_shots.stop()
	_use_brain(boss_actions.pick_random())

func _on_pause_between_shots_timeout() -> void:
	shoot_controller_2d.create_a_projectile_from_argument(current_bullet_type)
