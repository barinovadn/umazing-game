extends AIController

var boof: int = 0



func _on_action(action: AIAction):
	movement_controller.current_area_index = boof % 2
	boof += 1
	
