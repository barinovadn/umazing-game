extends Resource
class_name ItemData

enum Rarity { COMMON, RARE, EPIC }

@export_group("Common")
@export var rarity: Rarity = Rarity.COMMON
@export var name: String = "Item"
@export var icon: Texture2D
@export_multiline var description: String = ""

@export_group("Amount")
@export var max_stack: int = 99
@export var amount: int = 1

@export_group("Flags")
@export var is_consumable: bool = false
@export var is_active: bool = false
@export var is_stackable: bool = false


func get_rarity_color() -> Color:
	match rarity:
		Rarity.COMMON: return Color.WHITE
		Rarity.RARE: return Color.AQUA
		Rarity.EPIC: return Color.DEEP_PINK
	return Color.WHITE


func use():
	pass
