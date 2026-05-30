extends Node


const SAVE_PATH := "user://savegame.save"
const START_LEVEL_INDEX := 1


func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(SceneManager.current_level_index)
		file.close()


func load_game(new_game: bool = false):
	if new_game or not FileAccess.file_exists(SAVE_PATH):
		SceneManager.go_to_level(START_LEVEL_INDEX, false)
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var saved_id = file.get_32()
		file.close()
		SceneManager.go_to_level(saved_id, false)
