@icon("player_movement_controller.png")
class_name PlayerMovementController2D
extends MovementController2D


enum Direction { LEFT, RIGHT, UP, DOWN }

## Action names from [InputMap] mapped to movement directions.
@export var movement_controls: Dictionary[Direction, String] = {
	Direction.LEFT: "ui_left",
	Direction.RIGHT: "ui_right",
	Direction.UP: "ui_up",
	Direction.DOWN: "ui_down",
	}


func _physics_process(_delta):
	if not movement_enabled:
		return
	
	var input_direction := get_input()
	
	if input_direction:
		move(movement_speed, input_direction)
	else:
		stop()
	
	character_body.move_and_slide()


## Returns the current input direction using [member Input.get_vector] and
## [member movement_controls].
func get_input() -> Vector2:
	return Input.get_vector(
		movement_controls[Direction.LEFT],
		movement_controls[Direction.RIGHT],
		movement_controls[Direction.UP],
		movement_controls[Direction.DOWN],
	)
