extends Bullet

@export var hit_interval: float = 1.0
@export var hits_amount: int = 3

@onready var timer: Timer = $Timer

var target_component: HurtComponent = null


func _on_area_entered(area: Area2D) -> void:
	if not _can_damage_team(area.team):
		return
	
	if target_component == null and area is HurtComponent and hits_amount > 0:
		target_component = area
		
		_crashed_into_hurt_component(area)
		visible = false
		
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
		
		_deal_periodic_damage()

func _deal_periodic_damage() -> void:
	if is_instance_valid(target_component):
		target_component.take_damage(_calc_damage(target_component))
		hits_amount -= 1
		
		if vfx_hit:
			vfx_hit.spawn(target_component.global_position)
		_play_random_sound(sounds_hit)
	else:
		destroy()
		return

	if hits_amount <= 0:
		destroy()
	else:
		timer.start(hit_interval)

func _on_timer_timeout() -> void:
	_deal_periodic_damage()
