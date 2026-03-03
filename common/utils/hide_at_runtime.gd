@icon("hide_at_runtime.png")
class_name HideAtRuntime
extends Node2D
## Hides [member target] and itself at runtime.


## The [Node2D] to hide at runtime. If not specified will try to use parent.
@export var target: Node2D
## Is [HideAtRuntime] enabled.
@export var enabled: bool = true


func _ready():
	if not enabled:
		return
	
	if not target:
		target = get_parent() as Node2D
	
	if target:
		target.visible = false
	visible = false
