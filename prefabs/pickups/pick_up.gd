extends Area2D


func _on_body_entered(area: RigidBody2D):
		area.collect()
