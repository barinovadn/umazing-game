extends Area2D


func _on_camera_cell_changed(new_cell: Vector2, _smooth_transition: bool) -> void:
	global_position = Vector2(320, 160) * new_cell


func _on_area_entered(area: Area2D) -> void:
	if area is EnemyController:
		print(area.get_path())
		area.activate_interaction()


func _on_area_exited(area: Area2D) -> void:
	if area is EnemyController:
		area.deactivate_interaction()
