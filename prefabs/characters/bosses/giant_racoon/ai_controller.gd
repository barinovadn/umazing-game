extends AIController

@export var vfxprofile: VFXProfile
@export var vfx_spawn_time: float = 1.0
@export var modification: Modifier
@export var shooting_positions: Array[Marker2D]
var current_index_shooting_positions: int = 0

var timer = Timer.new()
var current_action

@onready var path_dot_movement_controller_2d: PathDotMovementController2D = $PathDotMovementController2D
@onready var behaviour_follow_2d: BehaviourFollow2D = $BehaviourFollow2D


func _ai_ready():
	await get_tree().process_frame
	Game.timers.add_child(timer)
	timer.timeout.connect(_on_timer_timeout)

func _on_action(action: AIAction):
	shoot_controller.global_position = global_position
	shoot_controller.position_needed = false
	
	_check_connections()
	_show()
	
	if not timer.is_stopped():
		timer.stop()
	if action.action_name == "dig":
		modification.value = 1
		modification.duration = action.duration
		modification.operation = modification.Operation.increase
		character.stat_speed_ratio.add_modifier(str(modification.get_instance_id()), modification)
		_hide()
		timer.start(vfx_spawn_time)
		path_dot_movement_controller_2d.break_started.connect(_show)
		path_dot_movement_controller_2d.break_ended.connect(_hide)
	if action.action_name == "stones_from_roof":
		shoot_controller.position_needed = true
		shoot_controller.post_shot_cd_finished.connect(_on_post_shot_cd_finished)
		_on_post_shot_cd_finished()
	if action.action_name == "dig_and_shoot":
		shoot_controller.position_needed = true
		shoot_controller.post_shot_cd_finished.connect(_on_post_shot_cd_finished)
		_on_post_shot_cd_finished()
		
		modification.value = 1
		modification.duration = action.duration
		modification.operation = modification.Operation.increase
		character.stat_speed_ratio.add_modifier(str(modification.get_instance_id()), modification)
		
		_hide()
		
		timer.start(vfx_spawn_time)
		path_dot_movement_controller_2d.break_started.connect(_show)
		path_dot_movement_controller_2d.break_ended.connect(_hide)


func _on_timer_timeout():
	if not character.destroyed:
		pass
	Game.vfx_manager.spawn(vfxprofile.effect, global_position, vfxprofile.settings)


func _show():
	hurt_component.set_deferred("monitorable", true)
	hurt_component.set_deferred("monitoring", true)
	character.visible = true


func _hide():
	hurt_component.set_deferred("monitorable", false)
	hurt_component.set_deferred("monitoring", false)
	character.visible = false


func _on_post_shot_cd_finished():
	shoot_controller.position_new = shooting_positions[current_index_shooting_positions].global_position
	current_index_shooting_positions += 1
	if current_index_shooting_positions >= shooting_positions.size():
		current_index_shooting_positions = 0


func _check_connections():
	if shoot_controller.post_shot_cd_finished.is_connected(_on_post_shot_cd_finished):
		shoot_controller.post_shot_cd_finished.disconnect(_on_post_shot_cd_finished)
	if path_dot_movement_controller_2d.break_started.is_connected(_show):
		path_dot_movement_controller_2d.break_started.disconnect(_show)
	if path_dot_movement_controller_2d.break_ended.is_connected(_hide):
		path_dot_movement_controller_2d.break_ended.disconnect(_hide)
