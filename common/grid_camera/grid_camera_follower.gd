@icon("grid_camera_follower.png")
class_name GridCameraFollower2D
extends Node
## Makes sure that the [member target]'s center is in bounds of
## [member GridCamera2D.grid_cell].

@export var camera: GridCamera2D ## Controlled grid camera.
@export var target: Node2D ## The target to follow.
@export var enabled: bool = true ## Whether or not the controller should work.

@export_group("Teleportation", "teleport")
## If set to [code]true[/code] will ignore transition smoothing once
## the [member target] is [member teleport_distance] away or further.
@export var teleport_enabled: bool = true
@export var teleport_distance: float = 100.0 ## See [member teleport_enabled].


func _ready():
	if not camera:
		camera = get_parent() as GridCamera2D
	
	if not camera:
		push_error("\"grid_camera\" was not assigned and parent is not "
			+ "GridCamera2D. Disabling controller.")
		enabled = false


func _process(_delta):
	if not enabled or not target or not camera:
		return
	
	var smoothing := true
	
	if teleport_enabled and get_distance() > teleport_distance:
		smoothing = false
	
	camera.snap_to_position(target.global_position, smoothing)


## Returns current distance to [member target] if it exists or [code]-1[/code].
func get_distance() -> float:
	if not target or not camera:
		return -1
	return camera.global_position.distance_to(target.global_position)
