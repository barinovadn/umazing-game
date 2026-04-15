extends EnemyController

@export var boss_name: String
@export var data_for_interface: BossUIData

var appeared: bool = false


func on_damaged():
	%Player/%BossUI.update_health(boss_name, hurt_controller.current_health)
	_check_phase()

func on_fatal_damage_taken():
	deactivate_interaction()
	_set_portals()
	%Player/%BossUI.remove_boss(boss_name)


func _ready() -> void:
	hurt_controller.damaged.connect(on_damaged)
	hurt_controller.fatal_damage_taken.connect(on_fatal_damage_taken)


func _use_brain(action: Action):
	if !appeared:
		appeared = true
		%Player/%BossUI.show_boss(boss_name, hurt_controller.current_health,
		hurt_controller.max_health, data_for_interface)
	if current_movement:
		current_movement.movement_enabled = false
	match action.action_name:
			"homing_shot":
				current_movement = movement_patterns["CatEnemyDTD"]
				pause_between_shots.wait_time = 0.8
				current_bullet_type = bullet_types[0]
				pause_between_shots.start()
				current_movement.movement_enabled = true
			"stone_shot":
				current_movement = movement_patterns["CatEnemyDTD"]
				pause_between_shots.wait_time = 0.8
				current_bullet_type = bullet_types[1]
				pause_between_shots.start()
				current_movement.movement_enabled = true
			"bunch_of_shots":
				current_movement = movement_patterns["CatEnemyDTD"]
				pause_between_shots.wait_time = 1.3
				current_bullet_type = bullet_types[2]
				pause_between_shots.start()
				current_movement.movement_enabled = false
