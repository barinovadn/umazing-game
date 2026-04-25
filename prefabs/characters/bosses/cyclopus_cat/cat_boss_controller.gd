extends EnemyController

var appeared: bool = false

func _use_brain(action: Action):
	if !appeared:
		appeared = true
		BossInterface.show_boss(enemy_name, hurt_controller.current_health,
		hurt_controller.max_health, data_for_interface)
	if current_movement:
		current_movement.movement_enabled = false
	if current_phase == 3:
		shoot_controller.is_bounce_on = true
		shoot_controller.number_of_bounces = 1
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
