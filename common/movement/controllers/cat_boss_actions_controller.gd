extends Node2D

@export var bullet_types: Array[Resource]
@export var boss_actions: Array[Action]

@onready var action_changer: Timer = $ActionChanger
@onready var pause_between_shots: Timer = $PauseBetweenShots
@onready var shoot_controller_2d: ShootController2D = $"../ShootController2D"

var current_bullet_type : Resource

func use_brain(action: Action):
	match action.action_name:
			"homing_shot":
				pause_between_shots.wait_time = 0.8
				current_bullet_type = bullet_types[0]
				pause_between_shots.start()
			"stone_shot":
				pause_between_shots.wait_time = 0.6
				current_bullet_type = bullet_types[1]
				pause_between_shots.start()

func _on_action_changer_timeout() -> void:
	pause_between_shots.stop()
	use_brain(boss_actions.pick_random())

func _on_pause_between_shots_timeout() -> void:
	shoot_controller_2d.create_a_projectile_from_argument(current_bullet_type)
