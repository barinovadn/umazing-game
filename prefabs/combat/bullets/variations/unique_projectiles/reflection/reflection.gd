extends Bullet

@export var damage_scale: float = 1.0
@export var speed_scale: float = 1.0

@export_group("Behavior")
@export var cd_enble_interval: float = 0.1
@export var cd_disable_interval: float = 1.0
@export_group("Destruction")
@export var is_unbrocable: bool = false
@export var can_destroy_bullets: bool = false
@export_group("VFX", "vfx")
@export var vfx_success: VFXProfile

@onready var timer_enable: Timer = $TimerEnable
@onready var timer_disable: Timer = $TimerDisable


var can_reflect: bool = false
var on_cd_reflect: bool = false


func _on_area_entered(area: Area2D):
	if !can_reflect or on_cd_reflect or not _can_damage_team(area.team) or area is HurtComponent:
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
		
		bullet.damage *= damage_scale
		bullet.speed *= speed_scale
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
