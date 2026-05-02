extends MovementController2D
class_name AreaMovementController

@export var regions: Array[NavigationRegion2D]
## Determines which area will be used to select points. Set from [BossController]
@export var current_area_index: int = 0
## Determines will points from random areas be used.
## If the answer is yes, it overwrites the current index with a random value
@export var use_random_area_points: bool = false
## Radius, to specify the minimum distance at which a point will be selected
@export var min_radius: float = 0.0
@export_range(0.001, 60) var break_time: float = 1.0:
	set(value):
		break_time = value
		if break_time > 0 and timer != null:
			timer.wait_time = break_time

@export_group("Stuck Detection", "stuck")
## How long (in seconds) the character must be stuck before picking a new target.
@export var stuck_threshold_time: float = 1.0
## If the character moves less than this distance (in pixels) per physics frame, they are considered stuck.
@export var stuck_threshold_distance: float = 0.5


var timer: Timer
var navigation_agent_2d: NavigationAgent2D

var _is_on_break_time: bool = false
var _stuck_timer: float = 0.0
var _last_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = break_time
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	navigation_agent_2d = NavigationAgent2D.new()
	navigation_agent_2d.path_desired_distance = 12.0
	add_child(navigation_agent_2d)
	
	if break_time > 0:
		timer.wait_time = break_time
	call_deferred("character_setup")


func _physics_process(_delta : float) -> void:
	if _is_on_break_time or !regions.size():
		return
		
	if navigation_agent_2d.is_navigation_finished():
		_stuck_timer = 0.0
		if break_time > 0:
			movement_enabled = false
			_is_on_break_time = true
			timer.start()
			return
		set_movement_target()
	
	var distance_moved = _last_position.distance_to(global_position)
	
	if distance_moved <= stuck_threshold_distance:
		_stuck_timer += _delta
		if _stuck_timer >= stuck_threshold_time:
			set_movement_target()
			return
	else:
		_stuck_timer = 0.0
		
	_last_position = global_position
	
	var target_position : Vector2 = navigation_agent_2d.get_next_path_position()
	var target_direction = global_position.direction_to(target_position).normalized()
	
	move(movement_speed, target_direction)


func _on_timer_timeout() -> void:
	_is_on_break_time = false
	movement_enabled = true
	set_movement_target()

## Verifying that the points appear on the map
func character_setup() -> void:
	var max_attempts = 100
	var attempts = 0
	while attempts < max_attempts:
		await get_tree().physics_frame
		var test_point = NavigationServer2D.map_get_random_point(
			navigation_agent_2d.get_navigation_map(),
			navigation_agent_2d.navigation_layers,
			false
		)
		if test_point != Vector2.ZERO:
			break
		attempts += 1
	set_movement_target()
	_last_position = global_position

## Selects a new targetpoint
func set_movement_target() -> void:
	if use_random_area_points:
		current_area_index = randi() % regions.size() - 1
		
	for i in range(0, regions.size()):
		if i != current_area_index:
			regions[i].navigation_layers = 0
		else: 
			regions[i].navigation_layers = navigation_agent_2d.navigation_layers
	
	var target_position: Vector2 = NavigationServer2D.map_get_random_point(navigation_agent_2d.get_navigation_map(), navigation_agent_2d.navigation_layers, false)
	
	if !min_radius:
		var _delta: float = 0.0
		while global_position.distance_squared_to(target_position) < min_radius:
			if _delta > 1.0:
				min_radius /= 2
			_delta += 0.017
			target_position = NavigationServer2D.map_get_random_point(navigation_agent_2d.get_navigation_map(), navigation_agent_2d.navigation_layers, false)
	navigation_agent_2d.target_position = target_position
	_stuck_timer = 0.0
