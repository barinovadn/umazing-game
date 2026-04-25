extends Area2D


func _on_camera_cell_changed(new_cell: Vector2, _smooth_transition: bool) -> void:
	global_position = Vector2(320, 160) * new_cell
