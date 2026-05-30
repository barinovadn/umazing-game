extends Resource
class_name ItemData


enum Rarity { COMMON, RARE, EPIC }

@export var rarity: Rarity = Rarity.COMMON
@export var name: String = "Item"
@export var icon: Texture2D
@export var amount: int = 1
@export var max_stack: int = 99
@export var description: Array[Dialogue]
@export var description_on_use: Array[Dialogue]

@export_group("Flags")
@export var is_consumable: bool = false
@export var is_active: bool = false
@export var is_stackable: bool = false

@export_group("Effects")
@export var heal: float = 0.0
@export var max_hp_increase: float = 0.0

@export_group("Visuals & Sounds", "rarity")
@export var rarity_colors: Dictionary[Rarity, Color] = {
	Rarity.COMMON: Color.WHITE,
	Rarity.RARE: Color.AQUA,
	Rarity.EPIC: Color.GREEN_YELLOW,
	}
@export var rarity_spawn_vfx: Dictionary[Rarity, VFXProfile] = {
	Rarity.COMMON: null,
	Rarity.RARE: null,
	Rarity.EPIC: null,
	}
@export var rarity_collect_vfx: Dictionary[Rarity, VFXProfile] = {
	Rarity.COMMON: null,
	Rarity.RARE: null,
	Rarity.EPIC: null,
	}
@export var rarity_sounds: Dictionary[Rarity, AudioStream] = {
	Rarity.COMMON: preload("res://prefabs/inventory/pickups/collect_common.ogg"),
	Rarity.RARE: preload("res://prefabs/inventory/pickups/collect_epic.ogg"),
	Rarity.EPIC: preload("res://prefabs/inventory/pickups/collect_rare.ogg"),
	}


func is_in_inventory():
	if Game.player and Game.player.inventory:
		return Game.player.inventory.has_item(name, 1)
	return false


func get_total_amount():
	if Game.player and Game.player.inventory:
		return Game.player.inventory.get_item_amount(name)
	return 0


func use():
	Game.player.hurt_component.max_health += max_hp_increase
	Game.player.hurt_component.current_health += heal
	if len(description_on_use):
		Game.dialogue_system.display(description_on_use.pick_random())
