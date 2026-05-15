extends Bullet

@export var cd_enble_interval: float = 0.1
@export var cd_disable_interval: float = 1.0

@export var is_unbrocable: bool = false
@export var can_destroy_bullets: bool = false

@onready var timer_enable: Timer = $TimerEnable
@onready var timer_disable: Timer = $TimerDisable


var can_reflect: bool = false
var on_cd_reflect: bool = false

func _on_area_entered(area: Area2D):
	if (!can_reflect or on_cd_reflect) or area.team == team or area is HurtComponent:
		return
	if area is Bullet:
		area.team = team
		if is_unbrocable:
			area.can_be_broken = false
		else:
			area.can_be_broken = false
		if can_destroy_bullets:
			area.can_break = true
		else:
			area.can_break = false
		area.set_target_direction()
		


func enable():
	can_reflect = true
	timer_enable.start(cd_enble_interval)
	

func disable():
	can_reflect = false


func _on_timer_enable_timeout() -> void:
	disable()
	on_cd_reflect = true
	timer_disable.start(cd_disable_interval)


func _on_timer_disable_timeout() -> void:
	on_cd_reflect = false
