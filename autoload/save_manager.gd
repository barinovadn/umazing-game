extends Node


const SAVE_PATH := "user://savegame.save"
const START_LEVEL_INDEX := 1

var loaded_items: Array[ItemData] = []


func save_game():
	var save_data = {
		"current_level_index": SceneManager.current_level_index,
		"inventory_items": Game.player.inventory.items,
		}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data, true)
		file.close()


func load_game(new_game: bool = false):
	loaded_items.clear()
	
	if new_game or not FileAccess.file_exists(SAVE_PATH):
		SceneManager.go_to_level(START_LEVEL_INDEX, false)
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var save_data = file.get_var(true)
		file.close()
		
		if save_data is Dictionary:
			if save_data.has("inventory_items"):
				var items_raw = save_data["inventory_items"]
				for item in items_raw:
					if item is ItemData:
						loaded_items.append(item)
						print(item)
			
			var saved_id = save_data.get("current_level_index", START_LEVEL_INDEX)
			SceneManager.go_to_level(saved_id, false)
