@icon("player_movement_controller.png")
class_name PlayerMovementController2D
extends MovementController2D


enum Action {
	LEFT, ## Go left.
	RIGHT, ## Go right.
	UP, ## Go up.
	DOWN, ## Go down.
	MOUSE, ## Go towards the mouse.
	}

## Used to track [member Player.character]'s [member Node2D.global_position]
## for the [member Action.MOUSE] type movement.
@export var player: Player
## Action names from [InputMap] mapped to movement [enum Action].
@export var controls: Dictionary[Action, String] = {
	Action.LEFT: "ui_left",
	Action.RIGHT: "ui_right",
	Action.UP: "ui_up",
	Action.DOWN: "ui_down",
	}

@export_group("Mouse", "mouse")
## Minimum distance the mouse has to be from the player's character to allow
## for the [member Action.MOUSE] type movement.
@export var mouse_dead_zone: float = 1.0
## Distance from screen edge (in pixels) to trigger edge-based movement.
@export var mouse_edge_margin: float = 10.0


func _physics_process(_delta):
	if not movement_enabled:
		return
	
	var input_direction := get_input_direction()
	
	if input_direction:
		move(movement_speed, input_direction)
	else:
		stop()


func _is_mouse_active() -> bool:
	return ( controls.has(Action.MOUSE)
		and Input.is_action_pressed(controls[Action.MOUSE]) )


func _get_screen_edge_direction() -> Vector2:
	var viewport := get_viewport().get_visible_rect()
	var mouse := get_viewport().get_mouse_position()
	
	if mouse.x <= mouse_edge_margin:
		return Vector2.LEFT
	if mouse.x >= viewport.size.x - mouse_edge_margin:
		return Vector2.RIGHT
	if mouse.y <= mouse_edge_margin:
		return Vector2.UP
	if mouse.y >= viewport.size.y - mouse_edge_margin:
		return Vector2.DOWN
	
	return Vector2.ZERO


func _get_mouse_direction() -> Vector2:
	var edge_dir := _get_screen_edge_direction()
	if edge_dir:
		return edge_dir
	
	var mouse_pos := player.character.get_global_mouse_position()
	var player_pos := player.character.global_position
	
	if player_pos.distance_to(mouse_pos) <= mouse_dead_zone:
		return Vector2.ZERO
	
	return player_pos.direction_to(mouse_pos)


func _get_keyboard_direction() -> Vector2:
	return Input.get_vector(
		controls[Action.LEFT],
		controls[Action.RIGHT],
		controls[Action.UP],
		controls[Action.DOWN],
	)


## Returns current movement direction using [member Input] and [member controls].
func get_input_direction() -> Vector2:
	if _is_mouse_active():
		return _get_mouse_direction()
	
	return _get_keyboard_direction()
