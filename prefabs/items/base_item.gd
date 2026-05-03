extends Resource
class_name ItemData

@export var name: String = "Item"
@export var icon: Texture2D
@export var max_stack: int = 99 
@export var amount: int = 1
@export var description: String = ""
@export var is_consumable: bool = false
@export var is_active: bool = false
@export var is_stackable: bool = false


func use(): pass
