extends AIController

var activated: int = 0


func _on_teleport_green_out_body_entered(_body: Node2D) -> void:
	activated+=1
	
	if activated == 2:
		await get_tree().create_timer(0.5).timeout
		character.movement = movement_patterns["follow_movement"]
