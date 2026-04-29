@icon("damage_area.png")
extends Bullet


@export_range(0.001, 60) var cooldown_time: float = 1.0:
	set(value):
		cooldown_time = value
		if timer:
			timer.wait_time = cooldown_time

@onready var timer: Timer = $Timer

var _can_damage: bool = true


func _bullet_ready():
	timer.wait_time = cooldown_time


func _on_area_entered(area: Area2D) -> void:
	if area.team == team:
		return
	if area is HurtComponent and _can_damage:
		_crashed_into_hurt_component()
		area.take_damage(_calc_damage())
		set_deferred("monitorable", false)
		set_deferred("monitoring", false)
		_can_damage = false
		timer.start()
		return


func _on_map_collision(_body: Node2D) -> void:
	pass


func _on_timer_timeout() -> void:
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)
	_can_damage = true
