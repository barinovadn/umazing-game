extends BossController

func _use_brain(action: Action):
	match action.action_name:
			"homing_shot":
				pause_between_shots.wait_time = 0.8
				current_bullet_type = bullet_types[0]
				pause_between_shots.start()
			"stone_shot":
				pause_between_shots.wait_time = 0.6
				current_bullet_type = bullet_types[1]
				pause_between_shots.start()
