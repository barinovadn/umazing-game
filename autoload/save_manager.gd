extends Node


const SAVE_PATH := "user://savegame.save"
const START_LEVEL_INDEX := 1

var loaded_items: Array[ItemData] = []
var loaded_hp: float = 0.0
var loaded_max_hp: float = 0.0
var loaded_speed_modifiers: Dictionary[String, Modifier] = {}
var loaded_armor_modifiers: Dictionary[String, Modifier] = {}
var loaded_damage_modifiers: Dictionary[String, Modifier] = {}
var loaded_shoot_speed_modifiers: Dictionary[String, Modifier] = {}
var loaded_playtime: float = 0.0


func _load_stat_modifiers(save_data: Dictionary,
	field: String) -> Dictionary[String, Modifier]:
	var result: Dictionary[String, Modifier] = {}
	var mods_raw = save_data.get(field, {})
	if not mods_raw is Dictionary:
		return result
	
	for key in mods_raw:
		var val = mods_raw[key]
		var mod = val as Modifier
		if key is String and mod:
			result[key] = mod
	return result


func _clear_loaded_data():
	loaded_items.clear()
	loaded_hp = 0.0
	loaded_max_hp = 0.0
	loaded_speed_modifiers.clear()
	loaded_armor_modifiers.clear()
	loaded_shoot_speed_modifiers.clear()
	loaded_playtime = 0.0


func save_game():
	var save_data = {
		"current_level_index": SceneManager.current_level_index,
		"inventory_items": Game.player.inventory.items,
		"current_health": Game.player.character.hurt_component.current_health,
		"max_health": Game.player.character.hurt_component.max_health,
		"speed_modifiers": Game.player.character.stat_speed_ratio.modifications,
		"armor_modifiers": Game.player.character.stat_armor.modifications,
		"damage_modifiers": Game.player.character.stat_damage_ratio.modifications,
		"shoot_speed_modifiers":
			Game.player.character.stat_shooting_speed.modifications,
		"playtime": Game.player.playtime,
		}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data, true)
		file.close()


func load_game(new_game: bool = false):
	_clear_loaded_data()
	
	if new_game or not FileAccess.file_exists(SAVE_PATH):
		clear_save_data()
		SceneManager.go_to_level(START_LEVEL_INDEX, false)
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("Error reading save file, could not load data!")
		return
	
	var save_data = file.get_var(true)
	file.close()
	
	if not save_data is Dictionary:
		push_error("Error reading save data, save data is corrupt!")
		return
	
	# ITEMS
	if save_data.has("inventory_items"):
		var items_raw = save_data["inventory_items"]
		for item in items_raw:
			if item is ItemData:
				loaded_items.append(item)
	
	# HEALTH
	loaded_hp = save_data.get("current_health", 0.0)
	loaded_max_hp = save_data.get("max_health", 0.0)
	
	# STATS
	loaded_speed_modifiers = _load_stat_modifiers(save_data, "speed_modifiers")
	loaded_armor_modifiers = _load_stat_modifiers(save_data, "armor_modifiers")
	loaded_damage_modifiers = _load_stat_modifiers(save_data, "damage_modifiers")
	loaded_shoot_speed_modifiers = _load_stat_modifiers(save_data, "shoot_speed_modifiers")
	
	# PLAYTIME
	loaded_playtime = save_data.get("playtime", 0.0)
	
	# LEVEL
	var saved_id = save_data.get("current_level_index", START_LEVEL_INDEX)
	SceneManager.go_to_level(saved_id, false)


func clear_save_data():
	if FileAccess.file_exists(SAVE_PATH):
		var error = DirAccess.remove_absolute(SAVE_PATH)
		if error != OK:
			push_error("Failed to delete save file! Error code: ", error)
