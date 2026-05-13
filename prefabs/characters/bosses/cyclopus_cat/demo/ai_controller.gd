extends AIController

var appeared: bool = false
var boof: int = 0

func _use_brain(action: AIAction):
	if !appeared:
		appeared = true
		display_location.add(data_for_interface, self)
	
	if movement_controller:
		movement_controller.enabled = false
	
	if current_phase == 3:
		shoot_controller.projectile_bounce = true
		shoot_controller.projectile_bounces_min = 1
	
	movement_controller.current_area_index = boof % 2
	boof += 1
	
	match action.action_name:
		"homing_shots":
			pause_between_shots.wait_time = 0.7
			shoot_controller.enabled = true
			current_bullet_type = bullets[0]
			pause_between_shots.start()
			movement_controller.enabled = true
		"stone_shots":
			pause_between_shots.wait_time = 0.15
			shoot_controller.enabled = true
			current_bullet_type = bullets[1]
			pause_between_shots.start()
			movement_controller.enabled = true
		"bunch_of_shots":
			pause_between_shots.wait_time = 1.6 if current_phase == 3 else 0.8
			shoot_controller.enabled = true
			current_bullet_type = bullets[2]
			pause_between_shots.start()
			movement_controller.enabled = false
		"rest":
			shoot_controller.enabled = false
			current_bullet_type = bullets[1]
			movement_controller.enabled = true
	
	## WARNING TERRAIN, PULL UP, PULL UP, TERRAIN
	character.movement = movement_controller
