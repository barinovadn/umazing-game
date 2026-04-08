extends BossController

func get_closest_target():
	var targets = get_tree().get_nodes_in_group("hurt_components")
	
	
	var closest = null
	var closest_dist = INF

	for t in targets:
		if t.team == hurt_controller.team || t.team == CombatScript.team.neutral:
			continue  # пропускаем своих

		var target_pos = t.global_position
		var dist = global_position.distance_to(target_pos)

		if dist < closest_dist:
			closest_dist = dist
			closest = t

	return closest

func _use_brain(action: Action):
	match action.action_name:
			"homing_shot":
				var target = get_closest_target()
				shoot_controller_2d.target = target
				pause_between_shots.wait_time = 0.8
				current_bullet_type = bullet_types[0]
				pause_between_shots.start()
			"stone_shot":
				var target = get_closest_target()
				shoot_controller_2d.target = target
				pause_between_shots.wait_time = 0.6
				current_bullet_type = bullet_types[1]
				pause_between_shots.start()
