extends Node2D


var demo_level = preload("res://scenes/game/levels/demo.tscn")


func _ready():
	$Decorations/Animator.play("appear")


func _on_play_pressed():
	get_tree().change_scene_to_packed(demo_level)


func _on_quit_pressed():
	get_tree().quit()
