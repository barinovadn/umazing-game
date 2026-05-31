extends Bullet

@export var hit_interval: float = 1.0
@export var hits_amount: int = 1

@onready var timer: Timer = $Timer

func _on_area_entered(area: Area2D):
	if not _can_damage_team(area.team):
		return
	if hits_amount <= 0:
		destroy()
	if area is HurtComponent and hits_amount:
		_crashed_into_hurt_component(area)
		area.take_damage(_calc_damage(area))
		hits_amount -= 1
		return
	if area is Bullet and not _crashed_in_char:
		if can_be_broken and area.can_break:
			destroy()
		return


func _crashed_into_hurt_component(hurt_component: HurtComponent):
	hit.emit(hurt_component)
	if vfx_hit:
		vfx_hit.spawn(hurt_component.global_position)
	_crashed_in_char = true
	audio_player.stream = null
	audio_player.stop()
	_play_random_sound(sounds_hit)
	timer.start(hit_interval)
	stop_and_disable_interaction()


func _on_timer_timeout() -> void:
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)
