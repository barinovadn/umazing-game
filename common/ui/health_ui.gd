extends Control

class_name HealthUI

@onready var hearts_container = $HeartsContainer

const FULL_HEART = preload("uid://b3aon6kwl2aam")
const HALF_FULL_HEART = preload("uid://d1j81f2n3kl6")
const EMPTY_HEART = preload("uid://bfe7akq685uy0")

@export var x_size : int = 18
@export var y_size : int = 20

func update_health(current_hp: int, max_hp: int):
	# очищаем старые сердечки
	for child in hearts_container.get_children():
		child.queue_free()

	var max_hearts = ceil(max_hp / 2.0)
	var hp_left = current_hp

	for i in range(max_hearts):
		var heart = TextureRect.new()
		
		heart.custom_minimum_size = Vector2(x_size, y_size)

		if hp_left >= 2:
			heart.texture = FULL_HEART
			hp_left -= 2
		elif hp_left == 1:
			heart.texture = HALF_FULL_HEART
			hp_left -= 1
		else:
			heart.texture = EMPTY_HEART

		hearts_container.add_child(heart)
