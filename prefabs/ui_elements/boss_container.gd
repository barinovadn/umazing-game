extends Control

class_name BossContainer

@onready var bar: TextureProgressBar = $Bar
@onready var label: Label = $Label

func create_boss(boss_name: String, current_hp: int, max_hp: int, data: BossUIData = null):
	if data:
		bar.texture_under = data.texture_under
		bar.texture_progress = data.texture_progress
		bar.texture_over = data.texture_over
	
	bar.max_value = max_hp
	bar.value = current_hp
	
	label.text = boss_name


func update_hp(current_hp):
	bar.value = current_hp


func remove_boss():
	queue_free()
