extends Control
class_name BossContainer


@export var smoothing_speed: float = 1.0

@onready var bar: TextureProgressBar = $Bar
@onready var label: Label = $Label

var target_bar_value: float = 0


func _process(delta: float):
	bar.value = lerp(bar.value, target_bar_value, smoothing_speed * delta)


func create_boss(boss_name: String, current_hp: int, max_hp: int,
	data: BossUIData = null):
	if data:
		if data.texture_under:
			bar.texture_under = data.texture_under
		if data.texture_progress:
			bar.texture_progress = data.texture_progress
		if data.texture_over:
			bar.texture_over = data.texture_over
	
	bar.max_value = max_hp
	target_bar_value = current_hp
	
	label.text = boss_name


func update_hp(current_hp):
	target_bar_value = current_hp


func remove_boss():
	queue_free()
