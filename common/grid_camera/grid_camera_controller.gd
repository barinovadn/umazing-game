@icon("grid_camera_controller.png")
class_name GridCameraController2D
extends Node
## A simple manual controller for the [GridCamera2D].


enum Direction { LEFT, RIGHT, UP, DOWN }

@export var grid_camera: GridCamera2D
@export var controls: Dictionary[Direction, String] = {
	Direction.LEFT: "ui_left",
	Direction.RIGHT: "ui_right",
	Direction.UP: "ui_up",
	Direction.DOWN: "ui_down",
	}
@export var enabled: bool = true


func _ready():
	if not grid_camera:
		grid_camera = get_parent() as GridCamera2D
	
	if not grid_camera:
		push_error("\"grid_camera\" was not assigned and parent is not "
			+ "GridCamera2D. Disabling controller.")
		enabled = false


func _input(_event: InputEvent) -> void:
	if not enabled: return
	move_camera(get_input())


func get_input() -> Vector2:
	return Input.get_vector(
		controls[Direction.LEFT],
		controls[Direction.RIGHT],
		controls[Direction.UP],
		controls[Direction.DOWN],
	)


func move_camera(dir: Vector2):
	if not grid_camera: return
	grid_camera.move_by(dir)
