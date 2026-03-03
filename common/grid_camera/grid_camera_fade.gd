@icon("grid_camera_fade.png")
class_name GridCameraTransitionFade
extends CanvasLayer
## Automatically fades the screen when [member camera] does a non-smooth transition.


@export var camera: GridCamera2D: ## Grid camera to track.
	set(value):
		if value == camera:
			return
		
		if camera and camera.cell_changed.is_connected(_on_camera_cell_changed):
			camera.cell_changed.disconnect(_on_camera_cell_changed)
		
		camera = value
		
		if camera:
			camera.cell_changed.connect(_on_camera_cell_changed)
@export var color: Color: ## Fade color.
	set(value):
		color = value
		if rect:
			rect.color = value
@export var duration: float = 1.0 ## Fade out duration in seconds.
@export var enabled: bool = true ## Whether should track the [member camera] or not.
@export var rect: ColorRect: ## Optional custom [ColorRect] to use for fade.
	set(value):
		rect = value
		if rect:
			rect.color = color
			rect.modulate.a = 0.0


func _ready():
	if not camera:
		camera = get_parent() as GridCamera2D
	
	if not camera:
		push_warning("\"camera\" is not connected or found.")
	
	if not rect:
		_create_rect()


func _create_rect():
	if rect:
		return
	
	rect = ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rect)


func _on_camera_cell_changed(_cell: Vector2, smooth: bool):
	if enabled and not smooth:
		transition()


## Instantly fades to [member color], then fades out over [member duration] seconds.
func transition():
	if not rect:
		_create_rect()
	
	rect.modulate.a = 1.0
	create_tween().tween_property(rect, "modulate:a", 0.0, duration)
