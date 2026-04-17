@icon("player_movement_controller.png")
class_name PlayerMovementController2D
extends MovementController2D


enum Direction { LEFT, RIGHT, UP, DOWN, MOUSE }

## Used to track [member Player.character]'s [member Node2D.global_position]
## for the [member Direction.MOUSE] type movement.
@export var player: Player

@export_group("Movement", "movement")
## Action names from [InputMap] mapped to movement directions.
@export var movement_controls: Dictionary[Direction, String] = {
	Direction.LEFT: "ui_left",
	Direction.RIGHT: "ui_right",
	Direction.UP: "ui_up",
	Direction.DOWN: "ui_down",
	}
## Minimum distance the mouse has to be from the player's character to allow
## for the [member Direction.MOUSE] type movement.
@export var movement_mouse_dead_zone: float = 1.0


func _physics_process(_delta):
	if not movement_enabled:
		return
	
	var input_direction := get_input()
	
	if input_direction:
		move(movement_speed, input_direction)
	else:
		stop()


func _is_mouse_movement_ready() -> bool:
	return movement_controls.has(Direction.MOUSE) and player and player.character 


## Returns the current input direction using [member Input] and
## [member movement_controls].
func get_input() -> Vector2:
	if( _is_mouse_movement_ready()
		and Input.is_action_pressed(movement_controls[Direction.MOUSE]) ):
		var mouse_pos := player.character.get_global_mouse_position()
		var player_pos := player.character.global_position
		
		if player_pos.distance_to(mouse_pos) <= movement_mouse_dead_zone:
			return Vector2.ZERO
		
		return player_pos.direction_to(mouse_pos)
	
	return Input.get_vector(
		movement_controls[Direction.LEFT],
		movement_controls[Direction.RIGHT],
		movement_controls[Direction.UP],
		movement_controls[Direction.DOWN],
	)
