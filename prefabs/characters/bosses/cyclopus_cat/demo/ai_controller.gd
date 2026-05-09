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
		shoot_controller.is_bounce_on = true
		shoot_controller.number_of_bounces = 1
	
	movement_controller.current_area_index = boof % 2
	boof += 1
	
	match action.action_name:
		"homing_shots":
			pause_between_shots.wait_time = 0.7
			shoot_controller.can_shoot = true
			current_bullet_type = bullet_types[0]
			pause_between_shots.start()
			movement_controller.enabled = true
		"stone_shots":
			pause_between_shots.wait_time = 0.15
			shoot_controller.can_shoot = true
			current_bullet_type = bullet_types[1]
			pause_between_shots.start()
			movement_controller.enabled = true
		"bunch_of_shots":
			pause_between_shots.wait_time = 1.6 if current_phase == 3 else 0.8
			shoot_controller.can_shoot = true
			current_bullet_type = bullet_types[2]
			pause_between_shots.start()
			movement_controller.enabled = false
		"rest":
			shoot_controller.can_shoot = false
			current_bullet_type = bullet_types[1]
			movement_controller.enabled = true
	
	#character.movement = movement_controller
