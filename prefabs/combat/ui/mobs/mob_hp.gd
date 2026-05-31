class_name MobHP
extends Control


@export var smoothing_speed: float = 1.0
@export var hurt_component: HurtComponent
@export var data: BossContainerData

@onready var bar: TextureProgressBar = $Bar

var target_bar_value: float = 0


func _process(delta: float):
	bar.value = lerp(bar.value, target_bar_value, smoothing_speed * delta)


func _ready() -> void:
	if data:
		if data.texture_under: bar.texture_under = data.texture_under
		if data.texture_progress: bar.texture_progress = data.texture_progress
		if data.texture_over: bar.texture_over = data.texture_over
	if hurt_component:
		hurt_component.health_changed.connect(update)
		bar.max_value = hurt_component.max_health
		target_bar_value = hurt_component.current_health


func update(_value: float):
	bar.max_value = hurt_component.max_health
	target_bar_value = hurt_component.current_health


func delete():
	queue_free()
