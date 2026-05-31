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
@export var effect_id: String

@export_group("Flags")
@export var is_consumable: bool = false
@export var is_active: bool = false
@export var is_stackable: bool = false

@export_group("On use")
@export_subgroup("Effects")
@export var on_use_heal: float = 0.0
@export var on_use_max_hp_increase: float = 0.0

@export_subgroup("Modifiers")
@export var on_use_modifier_speed_ratio: Modifier
@export var on_use_modifier_armor: Modifier
@export var on_use_modifier_shooting_speed: Modifier

@export_group("Passive")
@export_subgroup("Effects")
@export var passive_max_hp_increase: float = 0.0

@export_subgroup("Modifiers")
@export var passive_modifier_speed_ratio: Modifier
@export var passive_modifier_armor: Modifier
@export var passive_modifier_shooting_speed: Modifier

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


func _on_item_added_to_inventory():
	Game.player.hurt_component.max_health += passive_max_hp_increase

	if Game.player.character:
		if passive_modifier_speed_ratio and Game.player.character.stat_speed_ratio:
			Game.player.character.stat_speed_ratio.add_modifier(effect_id, passive_modifier_speed_ratio)

		if passive_modifier_armor and Game.player.character.stat_armor:
			Game.player.character.stat_armor.add_modifier(effect_id, passive_modifier_armor)

		if passive_modifier_shooting_speed and Game.player.character.stat_shooting_speed:
			Game.player.character.stat_shooting_speed.add_modifier(effect_id, passive_modifier_shooting_speed)


func _on_item_removed_to_inventory():
	Game.player.hurt_component.max_health -= passive_max_hp_increase

	if Game.player.character:
		if passive_modifier_speed_ratio and Game.player.character.stat_speed_ratio:
			Game.player.character.stat_speed_ratio.remove_modifier(effect_id)

		if passive_modifier_armor and Game.player.character.stat_armor:
			Game.player.character.stat_armor.remove_modifier(effect_id)

		if passive_modifier_shooting_speed and Game.player.character.stat_shooting_speed:
			Game.player.character.stat_shooting_speed.remove_modifier(effect_id)


func is_in_inventory():
	if Game.player and Game.player.inventory:
		return Game.player.inventory.has_item(name, 1)
	return false


func get_total_amount():
	if Game.player and Game.player.inventory:
		return Game.player.inventory.get_item_amount(name)
	return 0


func use():
	Game.player.hurt_component.max_health += on_use_max_hp_increase
	Game.player.hurt_component.current_health += on_use_heal

	if Game.player.character:
		if on_use_modifier_speed_ratio and Game.player.character.stat_speed_ratio:
			Game.player.character.stat_speed_ratio.add_modifier(effect_id, on_use_modifier_speed_ratio)

		if on_use_modifier_armor and Game.player.character.stat_armor:
			Game.player.character.stat_armor.add_modifier(effect_id, on_use_modifier_armor)

		if on_use_modifier_shooting_speed and Game.player.character.stat_shooting_speed:
			Game.player.character.stat_shooting_speed.add_modifier(effect_id, on_use_modifier_shooting_speed)

	if len(description_on_use):
		Game.dialogue_system.display(description_on_use.pick_random())
