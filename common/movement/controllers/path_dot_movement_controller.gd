class_name PathDotMovementController2D
extends MovementController2D
## Moves by points on a given [Path2D].

signal break_started
signal break_ended

enum Order { RANDOM, SEQUENTIAL, BACK_AND_FORTH }

## The [Path2D] to move on.
@export var path: Path2D
## Determines the order in which [member Path2D.curve]'s points are visited.
@export var order: Order = Order.SEQUENTIAL
## The radius within which the object is considered to have reached a point.
@export var point_margin: float = 1.0

@export_group("Break", "break")
## The minimum time the object stays still after reaching a point.
@export var break_duration_min: float = 0.0
## The maximum time the object stays still after reaching a point.
@export var break_duration_max: float = 0.0

var break_timer: Timer
var break_time: float:
	get(): return randf_range(break_duration_min, break_duration_max)
var is_on_break: bool
var is_current_point_reached: bool:
	get():
		var distance_sq = global_position.distance_squared_to(current_point_position)
		return distance_sq <= point_margin ** 2
var current_point_index: int = -1
var current_point_position: Vector2:
	get():
		if current_point_index < 0:
			return Vector2.ZERO
		var point = path.curve.get_point_position(current_point_index)
		return path.to_global(point)
var current_point_direction: Vector2:
	get():
		return (current_point_position - global_position).normalized()
var back_and_forth_direction: int = 1


func _ready():
	_create_break_timer()
	pick_new_target()


func _physics_process(_delta):
	if is_on_break:
		return
	
	if is_current_point_reached:
		if break_start():
			return
		else:
			pick_new_target()
	
	move(speed, current_point_direction)


func _create_break_timer():
	break_timer = Timer.new()
	break_timer.one_shot = true
	break_timer.timeout.connect(_on_break_ended)
	add_child(break_timer)


func _on_break_ended():
	is_on_break = false
	break_ended.emit()
	pick_new_target()


func _get_next_point_index() -> int:
	if not path: return -1
	
	match path.curve.point_count:
		0: return -1
		1: return 0
	
	match order:
		Order.RANDOM:
			var points := range(0, path.curve.point_count)
			points.erase(current_point_index)
			return points.pick_random()
		Order.SEQUENTIAL:
			return (current_point_index + 1) % path.curve.point_count
		Order.BACK_AND_FORTH:
			var next = current_point_index + back_and_forth_direction
			if next < 0 or next >= path.curve.point_count:
				back_and_forth_direction *= -1
				next = current_point_index + back_and_forth_direction
			return next
	return -1


func pick_new_target():
	current_point_index = _get_next_point_index()


func break_start(duration: float = -1.0) -> float:
	if duration <= 0:
		duration = break_time
	if not break_timer or duration <= 0:
		return 0
	
	stop()
	break_started.emit()
	is_on_break = true
	break_timer.start(duration)
	return duration


func break_stop():
	if break_timer:
		break_timer.stop()
	_on_break_ended()
