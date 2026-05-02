extends EnemyController

var appeared: bool = false
var boof: int = 0

func _use_brain(action: Action):
	if !appeared:
		appeared = true
		display_location.show_boss(display_name, hurt_component.current_health,
		hurt_component.max_health, data_for_interface)
	
	if current_movement:
		current_movement.movement_enabled = false
	
	if current_phase == 3:
		shoot_controller.is_bounce_on = true
		shoot_controller.number_of_bounces = 1
	
	print(action.action_name)
	match action.action_name:
		"homing_shot":
			current_movement = movement_patterns["CatEnemyDTD"]
			pause_between_shots.wait_time = 0.8
			shoot_controller.can_shoot = true
			current_bullet_type = bullet_types[0]
			pause_between_shots.start()
			current_movement.movement_enabled = true
		"stone_shot":
			current_movement = movement_patterns["CatAreaMovement"]
			current_movement.current_area_index = boof % 2
			boof+=1
			pause_between_shots.wait_time = 0.8
			shoot_controller.can_shoot = true
			current_bullet_type = bullet_types[1]
			pause_between_shots.start()
			current_movement.movement_enabled = true
		"bunch_of_shots":
			current_movement = movement_patterns["CatEnemyDTD"]
			pause_between_shots.wait_time = 1.3
			shoot_controller.can_shoot = true
			current_bullet_type = bullet_types[2]
			pause_between_shots.start()
			current_movement.movement_enabled = false
		"rest":
			current_movement = movement_patterns["CatAreaMovement"]
			current_movement.current_area_index = boof % 2
			boof+=1
			pause_between_shots.wait_time = 1.3
			shoot_controller.can_shoot = false
			current_bullet_type = bullet_types[1]
			pause_between_shots.start()
			current_movement.movement_enabled = true
	
	character.movement = current_movement
