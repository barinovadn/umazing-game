@icon("shoot_controller.png")
class_name ShootController
extends Node2D


signal shooting_started()
signal shooting_stopped()
signal shooting_is_available()
signal post_shot_cd_started()
signal post_shot_cd_finished()

@export var team := HurtComponent.Team.NEUTRAL
@export var bullets: Array[PackedScene]
@export_range(0.001, 60) var interval_between_shots: float = 0.4
@export var enabled: bool = true
@export var post_shot_cd_interval: float = 0.2

@export_group("Projectile Behavior", "projectile")
@export var projectile_homing: bool
@export var projectile_turn_rate_min: float = 0.0
@export var projectile_bounce: bool
@export var projectile_bounces_min: int = 1
@onready var animation_cooldown: Timer = $AnimationCooldown

@onready var cooldown_timer: Timer = $Cooldown


var direction: Vector2
## Indicates whether the component is in firing mode
## (is waiting for the post-firing delay)
var is_shooting: bool = false:
	set(value):
		if value == is_shooting:
			return
		is_shooting = value
		if is_shooting:
			if cooldown_timer != null:
				cooldown_timer.start(interval_between_shots)
			shooting_started.emit()

var on_shoot_cooldown: bool
var is_animation_needed: bool = false:
	set(value):
		is_animation_needed = value
		if is_animation_needed and animation_cooldown:
			animation_cooldown.start(post_shot_cd_interval)


func _on_cooldown_ended():
	on_shoot_cooldown = false
	if is_shooting:
		shoot()
	else:
		shooting_is_available.emit()


func _direction_to(target: Node2D) -> Vector2:
	if not target:
		return Vector2.ZERO
	return (target.global_position - global_position).normalized()


func _apply_behavior(bullet: Bullet):
	
	bullet.team = team
	
	bullet.global_position = global_position
	
	bullet.direction = direction
	
	bullet.homing = projectile_homing
	
	if projectile_bounce:
		bullet.bounces = max(projectile_bounces_min, bullet.bounces)
	bullet.turn_rate = max(bullet.turn_rate, projectile_turn_rate_min)


func shoot():
	if on_shoot_cooldown or not enabled or not bullets:
		return
	
	is_shooting = true
	
	var bullet = bullets.pick_random().instantiate() as Bullet
	_apply_behavior(bullet)
	Game.bullets.add_child(bullet)
	
	is_animation_needed = true
	post_shot_cd_started.emit()
	
	on_shoot_cooldown = true
	cooldown_timer.start(interval_between_shots)


func stop_shooting():
	is_shooting = false
	shooting_stopped.emit()


func set_bullet_array(array: Array[PackedScene]):
	bullets = array


func _on_animation_cooldown_timeout() -> void:
	is_animation_needed = false
	post_shot_cd_finished.emit()
