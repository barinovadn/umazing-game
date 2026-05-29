extends AIController


@export var paths_array: Dictionary[String, Path2D]

var current_path_index: int = 0


func _on_death():
	var env: EnvironmentParticles = Game.env_particles
	env.set_particles(env.Type.FOG, false)


func _on_phase_changed():
	var env: EnvironmentParticles = Game.env_particles
	match current_phase:
		2:
			env.set_particles(env.Type.SUNRAYS, true, env.Ratio.SMALL)
			env.set_particles(env.Type.FOG, true, env.Ratio.MEDIUM)
		3:
			shoot_controller.projectile_bounce = true
			shoot_controller.projectile_bounces_min = 2
			
			env.set_particles(env.Type.SUNRAYS, false)
			env.set_particles(env.Type.FOG, true, env.Ratio.LARGE)


func _on_action(action: AIAction):
	match action.action_name:
		"homing_shot":
			movement_controller.order = PathDotMovementController2D.Order.SEQUENTIAL
			movement_controller.path = paths_array["path_1"]
		"stone_bounce":
			movement_controller.order = PathDotMovementController2D.Order.BACK_AND_FORTH
			movement_controller.current_point_index = 0
			movement_controller.path = paths_array["path_2"]
		"multi_shot":
			movement_controller.order = PathDotMovementController2D.Order.SEQUENTIAL
			movement_controller.current_point_index = 0
			movement_controller.path = paths_array["path_2"]
