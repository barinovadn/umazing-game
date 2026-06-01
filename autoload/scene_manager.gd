extends Node


const LEVEL_FOLDER := "res://scenes/game/levels/"
const LEVEL_MAP: Dictionary = {
	0: "demo",
	1: "1_abandoned_village",
	2: "demo",
	}

## NOTE: Ready-only, use [method go_to_level] instead.
var current_level_index: int = 1


func go_to_level(level_id: int, save_game: bool = true):
	if not LEVEL_MAP.has(level_id):
		push_error("Level #" + str(level_id) + " does not exist in LEVEL_MAP!")
		return
	
	current_level_index = level_id
	
	if save_game: SaveManager.save_game()
	
	var level_scene_path: String = LEVEL_FOLDER + LEVEL_MAP[level_id] + ".tscn"
	get_tree().change_scene_to_file.call_deferred(level_scene_path)
