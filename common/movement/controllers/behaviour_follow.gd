@icon("behaviour_follow.png")
class_name BehaviourFollow2D
extends MovementController2D
## Basic follow behavior for the [MovementController2D].


@export var target: Node2D ## The target to follow.
@export var body: Node2D ## The object that is following.

@export_group("Distance", "distance")
@export var distance_min: float = 25.0 ## Minimum distance to [member target].
@export var distance_max: float = 50.0 ## Maximum distance to [member target].

@export_group("Teleportation", "teleport")
## If set to [code]true[/code] will teleport to the [member target] once beyond
## [member teleport_distance].
@export var teleport_enabled: bool = true
@export var teleport_distance: float = 250.0 ## See [member teleport_enabled].


func _ready():
	if not body:
		body = get_parent() as Node2D
	if not body:
		push_warning("\"body\" is not specified or found. "
			+ "Controller will not be able to operate without body position.")


func _physics_process(_delta):
	if not movement_enabled or not target or not body:
		return
	
	var keep_moving := false
	var target_distance = get_distance()
	
	if teleport_enabled and target_distance > teleport_distance:
		teleport(target.global_position)
		return
	
	if is_moving:
		if target_distance < distance_min:
			stop()
		else:
			keep_moving = true
	elif target_distance > distance_max:
		keep_moving = true
	
	if keep_moving:
		move(movement_speed, get_direction())

func stop_moving():
	movement_enabled = false
	
func start_moving():
	movement_enabled = true

## Returns normalized direction towards the [member target] or [member Vector2.ZERO].
func get_direction() -> Vector2:
	if not body or not target:
		return Vector2.ZERO
	return body.global_position.direction_to(target.global_position)


## Returns current distance to [member target] if it exists or [code]-1[/code].
func get_distance() -> float:
	if not body or not target:
		return -1
	return body.global_position.distance_to(target.global_position)
