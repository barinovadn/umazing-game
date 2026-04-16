extends Area2D
class_name Pickup

@export var item_data: ItemData

@onready var sprite = $Sprite2D
@onready var inventory = %Player/%Inventory


func _ready():
	if item_data:
		sprite.texture = item_data.item_icon

	
func collect():
	if inventory.add_item(item_data):
		queue_free() 
	else:
		print("Предмет остался на полу :(")
