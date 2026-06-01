extends Node2D


var demo_level = preload("res://scenes/game/levels/demo.tscn")


func _ready():
	$Decorations/Animator.play("appear")


func _on_conitnue_pressed():
	SaveManager.load_game()


func _on_new_game_pressed():
	SaveManager.load_game(true)

func _on_button_demo_pressed():
	SceneManager.go_to_level(0, false)


func _on_quit_pressed():
	get_tree().quit()
