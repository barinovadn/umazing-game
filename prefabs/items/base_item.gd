extends Resource
class_name ItemData

@export var item_name: String = "Item"
@export var item_icon: Texture2D
@export var max_stack: int = 99
@export var description: String = ""
@export var is_consumable: bool = false

@export_enum("Active", "Passive") var item_type: String = "Active"

@export_group("Stats")
@export var heal_amount: int = 0
