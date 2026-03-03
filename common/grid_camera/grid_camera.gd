@icon("grid_camera.png")
class_name GridCamera2D
extends Camera2D
## Grid-based variant of [Camera2D]. Snaps camera position to cell centers.


## Emitted when the [member grid_cell] changes.
signal cell_changed(new_cell: Vector2, smooth_transition: bool)

## The size of a single grid cell in pixels.
@export var grid_size: Vector2 = Vector2.ONE * 100
## If set to [code]true[/code] will allow methods like [method set_cell] to
## update [member Camera2D.position_smoothing_enabled] on the fly.
@export var allow_smooth_transitions: bool = true

# NOTE Default is set to Vector2 with floats to trigger position snap in _ready.
## Index of the current active grid cell.
## [br][br][b]Note:[/b] It is recommended that you use methods like
## [method set_cell] to change this value, as they also update the
## [member position_smoothing_enabled] on every call.
var grid_cell: Vector2 = Vector2.ONE / 10:
	set(value):
		if grid_cell == value:
			return
		
		grid_cell = value.floor()
		global_position = _grid_to_world(grid_cell)
		
		cell_changed.emit(grid_cell, position_smoothing_enabled)


func _ready():
	snap_to_position(global_position, false)


## Transforms world position to grid cell index.
func _world_to_grid(world_pos: Vector2) -> Vector2:
	return ((world_pos + grid_size / 2) / grid_size).floor()


## Transforms grid cell index to world position. Returns cell center position.
func _grid_to_world(grid_pos: Vector2) -> Vector2:
	return grid_pos * grid_size


## Moves camera to the [param target_cell]. [member position_smoothing_enabled]
## is set to equal [param smoothing] on every call.
func set_cell(target_cell: Vector2, smoothing: bool = true):
	if allow_smooth_transitions:
		position_smoothing_enabled = smoothing
	grid_cell = target_cell


## Syntax sugar for [method set_cell].
## Roughly equal to [code]grid_cell += cell_offset[/code].
func move_by(cell_offset: Vector2, smoothing: bool = true):
	set_cell(grid_cell + cell_offset, smoothing)


## Uses [method set_cell] to snap camera to the cell closest to [param world_pos].
func snap_to_position(world_pos: Vector2, smoothing: bool = true):
	set_cell(_world_to_grid(world_pos), smoothing)
