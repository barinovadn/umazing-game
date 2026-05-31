class_name BossContainerUI
extends Control


@export var smoothing_speed: float = 1.0

@onready var bar: TextureProgressBar = $Bar
@onready var label: Label = $Label

var target_bar_value: float = 0


func _process(delta: float):
	bar.value = lerp(bar.value, target_bar_value, smoothing_speed * delta)


func update(data: BossContainerData, controller: AIController):
	if data.texture_under: bar.texture_under = data.texture_under
	if data.texture_progress: bar.texture_progress = data.texture_progress
	if data.texture_over: bar.texture_over = data.texture_over
	label.text = data.display_name
	label.add_theme_color_override("font_color", data.display_color)
	bar.max_value = controller.hurt_component.max_health
	target_bar_value = controller.hurt_component.current_health


func delete():
	queue_free()
