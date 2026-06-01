extends AIController

@export var shooting_positions: Array[Marker2D]


var current_index_shooting_positions: int = 0

@onready var marker_center: Marker2D = $"../../MarkerCenter"
@onready var marker_right: Marker2D = $"../../MarkerRight"
@onready var behaviour_follow_2d: BehaviourFollow2D = $BehaviourFollow2D

func _on_action(_action: AIAction):
	shoot_controller.global_position = global_position
	shoot_controller.position_needed = false
	
	_check_connections()
	
	if _action.action_name == "wave":
		behaviour_follow_2d.target = marker_right
		shoot_controller.position_needed = true
		current_index_shooting_positions += 1
		if current_index_shooting_positions >= shooting_positions.size():
			current_index_shooting_positions = 0
		shoot_controller.post_shot_cd_finished.connect(_on_post_shot_cd_finished)
		_on_post_shot_cd_finished()
	if _action.action_name == "center_circle":
		behaviour_follow_2d.target = marker_center


func _on_post_shot_cd_finished():
	shoot_controller.position_new = shooting_positions[current_index_shooting_positions].global_position


func _check_connections():
	if shoot_controller.post_shot_cd_finished.is_connected(_on_post_shot_cd_finished):
		shoot_controller.post_shot_cd_finished.disconnect(_on_post_shot_cd_finished)
