extends AIController


@export var npc: Character2D
@export var npc_new_movement: MovementController2D

var boof: int = 0


func _on_death():
	var env = Game.env_particles
	env.disable_all()
	env.enable(env.Type.SUNRAYS, env.Ratio.MEDIUM)
	
	npc.global_position = global_position
	npc.movement = npc_new_movement


func _on_phase_changed():
	var env = Game.env_particles
	match current_phase:
		2:
			env.set_particles(env.Type.CLOUDS, true, env.Ratio.MEDIUM)
		3:
			shoot_controller.projectile_bounce = true
			shoot_controller.projectile_bounces_min = 1
			
			env.set_particles(env.Type.CLOUDS, true, env.Ratio.LARGE)


func _on_action(action: AIAction):
	movement_controller.current_area_index = boof % 2
	boof += 1
	
	match action.action_name:
		"bunch_of_shots":
			shoot_controller.interval_between_shots = 0.8 if current_phase == 3 else 1.6
