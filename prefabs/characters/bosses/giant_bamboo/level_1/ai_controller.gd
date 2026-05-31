extends AIController

var boof: int = 0

@export var bamboo_breakables: Array[Breakable2D]
@export var aim_positions: Array[Marker2D]
@export var vfx: VFXProfile


var sound
var damage_marker
var heal_marker


func _on_action(action: AIAction):
	if action.action_name == "hide and shot":
		shoot_controller.post_shot_cd_finished.connect(on_position_change)
	else:
		movement_controller.current_area_index = boof % 2
		boof += 1


func _on_phase_changed():
	if current_phase == 2:
		for el in bamboo_breakables:
			el.spawn()
			el.settings.respawn_duration_min = 6.5
			el.settings.respawn_duration_max = 7
			el.settings.sounds_break = sound
			el._hurt_component.vfx_damage_marker = damage_marker
			el._hurt_component.vfx_heal_marker = heal_marker
		_on_action_changer_timeout()


func _ai_ready():
	await get_tree().process_frame
	for el in bamboo_breakables:
		sound = el.settings.sounds_break
		damage_marker = el._hurt_component.vfx_damage_marker
		heal_marker = el._hurt_component.vfx_heal_marker
		
		el._hurt_component.vfx_damage_marker = null
		el._hurt_component.vfx_heal_marker = null
		el.settings.sounds_break[0] = null
		el.settings.respawn_duration_min = 10000
		el.settings.respawn_duration_max = 10000
		el._hurt_component.current_health = 0.0


func on_position_change():
	var nearest_marker = get_nearest_marker_to_player()
	
	if nearest_marker:
		shoot_controller.global_position = nearest_marker.global_position
	else:
		if not aim_positions.is_empty():
			shoot_controller.global_position = aim_positions.pick_random().global_position
	Game.vfx_manager.spawn(vfx.effect, shoot_controller.global_position)


func _on_death():
	for el in bamboo_breakables:
		el.destroy()
		el.delete()


func get_nearest_marker_to_player() -> Marker2D:
	var player = get_nearest_target()
	if not player or aim_positions.is_empty():
		return null
		
	var player_pos = player.global_position
	var nearest_marker: Marker2D = null
	var closest_dist = INF

	for marker in aim_positions:
		if not marker:
			continue
		var dist = marker.global_position.distance_to(player_pos)
		if dist < closest_dist:
			closest_dist = dist
			nearest_marker = marker

	return nearest_marker


func get_nearest_target() -> HurtComponent:
	if not is_inside_tree():
		return null
	
	var targets = get_tree().get_nodes_in_group("hurt_component")
	var nearest = null
	var closest_dist = INF

	for aim in targets:
		if (aim.team != HurtComponent.Team.PLAYER):
			continue
		
		var target_pos = aim.global_position
		var dist = global_position.distance_to(target_pos)
		
		if dist < closest_dist:
			closest_dist = dist
			nearest = aim

	return nearest
