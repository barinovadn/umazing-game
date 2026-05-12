extends RigidBody2D
class_name Pickup

@export var item_data: ItemData
@export var test_item: ItemData

@onready var sprite = $Icon
@onready var inventory = %Player/%Inventory
@onready var light = $Icon/RarityLight


func _ready():
	if item_data:
		sprite.texture = item_data.icon
	if test_item:
		set_light_by_rarity(test_item)


func set_light_by_rarity(data: ItemData):
	if light: 
		light.color = data.get_rarity_color()


func collect():
	var leftover = inventory.add_item(item_data)
	
	if leftover <= 0:
		queue_free()
	else:
		item_data.amount = leftover
