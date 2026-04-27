class_name PathDotMovementController2D
extends MovementController2D

@export var path: Path2D
## Determines whether points will be selected in
## the order they appear in [member path] or chosen at random
@export var ordered_use: bool
## Sets the current index of the node in [member path]
@export var current_movement_point_index: int = -1

## Sets the radius within which the character is considered to have reached the point.
@export var target_point_radius: float = 1.0
## Determines how long the character stands in one place after reaching the destination.
@export_range(0.001, 60) var break_time: float = 1.0:
	set(value):
		break_time = value
		if break_time > 0 and timer != null:
			timer.wait_time = break_time

var timer: Timer
var current_movement_point_position: Vector2
var move_direction: Vector2

var _is_on_break_time: bool = false


func _ready():
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = max(0.001, break_time)
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
		
	pick_new_target()


func _physics_process(_delta):
	if _is_on_break_time:
		return
	
	var distance_sq = global_position.distance_squared_to(current_movement_point_position)
	
	if distance_sq < target_point_radius**2:
		if break_time > 0:
			movement_enabled = false
			_is_on_break_time = true
			timer.start()
			return
		else:
			pick_new_target()
	
	move_direction = (current_movement_point_position - global_position).normalized()
	move(movement_speed, move_direction)


func pick_new_target():
	if !path or path.curve.point_count == 0:
		return
	
	var curve = path.curve
	var count = curve.point_count
	
	if count == 1:
		current_movement_point_position = path.to_global(curve.get_point_position(0))
	elif ordered_use:
		current_movement_point_index = (current_movement_point_index + 1) % count
		var local_point = curve.get_point_position(current_movement_point_index)
		current_movement_point_position = path.to_global(local_point)
	else:
		var new_index = randi() % count
		while new_index == current_movement_point_index:
			new_index = randi() % count
		
		current_movement_point_index = new_index
		
		var local_point = curve.get_point_position(current_movement_point_index)
		current_movement_point_position = path.to_global(local_point)


func _on_timer_timeout() -> void:
	_is_on_break_time = false
	movement_enabled = true
	pick_new_target()
