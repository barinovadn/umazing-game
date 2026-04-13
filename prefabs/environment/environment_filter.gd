@icon("environment_filter.png")
class_name EnvironmentFilter
extends CanvasLayer
## Displays environmental color effects.


## The color filter to be applied over the game screen.
## [br][b]Note:[/b] Make sure its semi-transparent, to avoid blocking all vizability!
@export var color: Color:
	set(value):
		color = value
		_transition()
## The duration of transition between [member color] changes.
@export var transition_duration: float = 1.0

@onready var rect: ColorRect = $Color


func _ready():
	_transition()


func _transition():
	if not rect:
		return
	create_tween().tween_property(rect, "color", color, transition_duration)
