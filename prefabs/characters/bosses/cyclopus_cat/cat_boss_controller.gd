extends EnemyController

@export var boss_name: String
@export var data_for_interface: BossUIData

var appeared: bool = false

func _ready() -> void:
	hurt_controller.damaged.connect(on_damaged)
	hurt_controller.fatal_damage_taken.connect(on_fatal_damage_taken)

func _use_brain(action: Action):
	if !appeared:
		appeared = true
		UiAdapter.data_for_interface = data_for_interface
		UiAdapter.boss_name = boss_name
		UiAdapter.current_hp = hurt_controller.current_health
		UiAdapter.max_hp = hurt_controller.max_health
		UiAdapter.show_boss.emit()
	
	match action.action_name:
			"homing_shot":
				current_movement = movement_patterns["CatEnemyDTD"]
				pause_between_shots.wait_time = 0.8
				current_bullet_type = bullet_types[0]
				pause_between_shots.start()
			"stone_shot":
				current_movement = movement_patterns["CatEnemyDTD"]
				pause_between_shots.wait_time = 0.6
				current_bullet_type = bullet_types[1]
				pause_between_shots.start()


func on_damaged():
	UiAdapter.boss_name = boss_name
	UiAdapter.current_hp = hurt_controller.current_health
	UiAdapter.max_hp = hurt_controller.max_health
	UiAdapter.update_health.emit()

func on_fatal_damage_taken():
	deactivate_interaction()
	UiAdapter.name = boss_name
	UiAdapter.remove_boss.emit()
	deactivate_portale(teleport_in)
	teleport_out.global_position = hurt_controller.global_position
	activate_portal(teleport_out)
