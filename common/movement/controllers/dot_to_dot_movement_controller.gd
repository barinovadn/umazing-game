class_name CatEnemyMovementController2D
extends MovementController2D

@export var movement_points: Array[Node2D]

## Is a pause used after reaching the goal
@export var break_time_available: bool = false

## Determines how long the character stands in one place after reaching the destination.
@export var break_time: float = 0.0:
	set(value):
		break_time = value
		if break_time_available and is_node_ready() and timer != null:
			timer.wait_time = break_time

## Sets the radius within which the character is considered to have reached the point.
@export var target_point_radius: float = 1.0

@onready var timer: Timer = $Timer
@onready var marker: Node2D = $Marker

var current_movement_point_position: Vector2
var move_direction: Vector2
var _is_on_break_time: bool = false


func _ready():
	if break_time_available and break_time > 0:
		timer.wait_time = break_time
		
	pick_new_target()


func _physics_process(_delta):
	if _is_on_break_time:
		return
	
	var global_position = marker.global_position
	var distance_sq = global_position.distance_squared_to(current_movement_point_position)
	
	if distance_sq < target_point_radius**2:
		if break_time_available:
			movement_enabled = false
			_is_on_break_time = true
			timer.start()
		else:
			pick_new_target()
	
	move_direction = (current_movement_point_position - global_position).normalized()
	move(movement_speed, move_direction)


func pick_new_target():
	if movement_points.is_empty():
		return
	var random_point = movement_points.pick_random()
	current_movement_point_position = random_point.global_position


func _on_timer_timeout() -> void:
	_is_on_break_time = false
	movement_enabled = true
	pick_new_target()
