extends Control
class_name HealthUI

@onready var hearts_container = $HeartsContainer

@export var hearts_image: Texture2D:
	set(value):
		hearts_image = value
		_generate_heart_textures()

@export var x_size: int = 18
@export var y_size: int = 20

var empty_heart: AtlasTexture
var quarter_heart: AtlasTexture
var half_heart: AtlasTexture
var three_quarter_heart: AtlasTexture
var full_heart: AtlasTexture

## Generates the atlas textures whenever the main spritesheet is updated
func _generate_heart_textures() -> void:
	if not hearts_image:
		return
		
	empty_heart = _create_atlas(Rect2(1, 3, 14, 11))
	quarter_heart = _create_atlas(Rect2(17, 3, 14, 11))
	half_heart = _create_atlas(Rect2(33, 3, 14, 11))
	three_quarter_heart = _create_atlas(Rect2(49, 3, 14, 11))
	full_heart = _create_atlas(Rect2(65, 3, 14, 11))

## Helper function to clean up atlas creation
func _create_atlas(region: Rect2) -> AtlasTexture:
	var atlas = AtlasTexture.new()
	atlas.atlas = hearts_image
	atlas.region = region
	return atlas

## Displays the player's HP on the screen using hearts
func update_health(current_hp: float, max_hp: float) -> void:
	var max_hearts: int = ceil(max_hp / 4.0)
	var current_nodes: int = hearts_container.get_child_count()
	
	# 1. Add missing heart nodes (if Max HP increased)
	while current_nodes < max_hearts:
		var heart = TextureRect.new()
		heart.custom_minimum_size = Vector2(x_size, y_size)
		hearts_container.add_child(heart)
		current_nodes += 1
		
	# 2. Remove excess heart nodes (if Max HP decreased)
	while current_nodes > max_hearts:
		var child = hearts_container.get_child(current_nodes - 1)
		hearts_container.remove_child(child)
		child.queue_free()
		current_nodes -= 1
		
	# 3. Update the textures of the existing nodes
	var hp_left: float = current_hp
	
	for i in range(max_hearts):
		var heart = hearts_container.get_child(i) as TextureRect
		
		if hp_left >= 4.0:
			heart.texture = full_heart
			hp_left -= 4.0
		elif hp_left >= 3.0:
			heart.texture = three_quarter_heart
			hp_left -= 3.0
		elif hp_left >= 2.0:
			heart.texture = half_heart
			hp_left -= 2.0
		elif hp_left >= 1.0:
			heart.texture = quarter_heart
			hp_left -= 1.0
		else:
			heart.texture = empty_heart
