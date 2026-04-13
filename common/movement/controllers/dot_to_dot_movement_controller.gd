class_name CatEnemyMovementController2D
extends MovementController2D

@export var enemy_movement_points: Node 

@onready var triger: Area2D = $Trigger

var movement_points: Array
var current_movement_point: Vector2
var move_direction: Vector2

func _ready():
	movement_points = enemy_movement_points.get_children()
	# Choose the first random target.
	pick_new_target()
	# Connect the death signal to stop movement when the enemy dies.

func pick_new_target():
	if movement_points.is_empty():
		return
	var random_point = movement_points.pick_random()
	current_movement_point = random_point.global_position
	pass

func _physics_process(_delta):
	var current_pos = triger.global_position
	var distance_sq = current_pos.distance_squared_to(current_movement_point)
	
	# If the enemy is very close to the target (within ~20 pixels), pick a new one.
	if distance_sq < 400.0:  # threshold = 20^2
		pick_new_target()
		# Recalculate direction toward the new target.
		var to_target = current_movement_point - current_pos
		if to_target.length_squared() > 0:
			move_direction = to_target.normalized()
		else:
			move_direction = Vector2.ZERO
	else:
		# Otherwise, continue moving toward the current target.
		var to_target = current_movement_point - current_pos
		move_direction = to_target.normalized()
	
	# If we have a valid direction, move; otherwise stop.
	if move_direction != Vector2.ZERO:
		move(movement_speed, move_direction)
	else:
		stop()
