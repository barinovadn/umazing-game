extends Control

class_name HealthUI

@onready var hearts_container = $HeartsContainer

@export var full_heart : AtlasTexture
@export var half_full_heart : AtlasTexture
@export var empty_heart : AtlasTexture

@export var x_size : int = 18
@export var y_size : int = 20

## Displays the player's HP on the screen using hearts
func update_health(current_hp: int, max_hp: int):
	for child in hearts_container.get_children():
		child.queue_free()
	
	var max_hearts = ceil(max_hp / 2.0)
	var hp_left = current_hp
	
	for i in range(max_hearts):
		var heart = TextureRect.new()
		
		heart.custom_minimum_size = Vector2(x_size, y_size)
		
		if hp_left >= 2:
			heart.texture = full_heart
			hp_left -= 2
		elif hp_left == 1:
			heart.texture = half_full_heart
			hp_left -= 1
		else:
			heart.texture = empty_heart
		
		hearts_container.add_child(heart)
