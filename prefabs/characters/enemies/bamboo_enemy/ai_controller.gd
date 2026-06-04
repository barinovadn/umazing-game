extends AIController


@export var teleport: Teleport


func _ai_ready():
	teleport.used.connect(func(): hurt_component.current_health = 0.0)
