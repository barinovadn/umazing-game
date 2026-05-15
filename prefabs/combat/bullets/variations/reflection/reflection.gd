extends Bullet

@export var cd_enble_interval: float = 0.1
@export var cd_disable_interval: float = 1.0

@export var is_unbrocable: bool = false
@export var can_destroy_bullets: bool = false

@export var vfx_success: VFXProfile

@onready var timer_enable: Timer = $TimerEnable
@onready var timer_disable: Timer = $TimerDisable


var can_reflect: bool = false
var on_cd_reflect: bool = false


func _on_area_entered(area: Area2D):
	if !can_reflect or on_cd_reflect or area.team == team or area is HurtComponent:
		return
	
	var bullet := area as Bullet
	
	if bullet:
		bullet.team = team
		
		if is_unbrocable:
			bullet.can_be_broken = false
		else:
			bullet.can_be_broken = false
		
		if can_destroy_bullets:
			bullet.can_break = true
		else:
			bullet.can_break = false
		
		bullet.damage *= 3
		bullet.speed *= 1.35
		vfx_success.spawn(bullet.global_position)
		_play_random_sound(sounds_hit)
		bullet.set_target_direction()


func enable():
	if on_cd_reflect or can_reflect:
		return
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
