extends RigidBody2D
class_name Pickup

@export var item_data: ItemData

@onready var sprite = $Sprite2D
@onready var inventory = %Player/%Inventory


func _ready():
	if item_data:
		sprite.texture = item_data.icon

	
func collect():
	var leftover = inventory.add_item(item_data)
	
	if leftover <= 0:
		queue_free()
	else:
		item_data.amount = leftover
