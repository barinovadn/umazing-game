extends AIController


@onready var teleport_pink_in: Teleport = $"../TeleportPinkIn"


func _ai_ready():
	teleport_pink_in.used.connect(func(): hurt_component.current_health = 0.0)
