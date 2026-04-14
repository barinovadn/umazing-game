extends Control
class_name BossUI

@onready var container: VBoxContainer = $Container

const BOSS_CONTAINER = preload("uid://dn3pwb4lu7m8l")

# name → {container}
var active_bars: Dictionary = {}

# показать босса
func show_boss(boss_name: String, current_hp: int, max_hp: int, data: BossUIData = null):
	if active_bars.has(boss_name):
		return
	var boss_data = BOSS_CONTAINER.instantiate()
	container.add_child(boss_data)
	boss_data.create_boss(boss_name, current_hp, max_hp, data)
	
	active_bars[boss_name] = {
		"container" : boss_data
	}

# обновить HP
func update_health(name_b: String, current_hp: int):
	if not active_bars.has(name_b):
		return
	var container_b: BossContainer = active_bars[name_b]["container"]
	container_b.update_hp(current_hp)

# убрать босса
func remove_boss(name_b: String):
	if not active_bars.has(name_b):
		return
	var container_b : BossContainer = active_bars[name_b]["container"]
	container_b.remove_boss()
	active_bars.erase(name_b)
