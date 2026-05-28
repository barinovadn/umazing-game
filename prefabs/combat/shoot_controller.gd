@icon("shoot_controller.png")
class_name ShootController
extends Node2D


signal shooting_started()
signal shooting_stopped()
signal shooting_is_available()
signal post_shot_cd_started()
signal post_shot_cd_finished()

@export var enabled: bool = true
@export var is_shooting: bool = false:
	set(value):
		if value == is_shooting:
			return
		is_shooting = value
		_shoot_state_changed()
@export var team := HurtComponent.Team.NEUTRAL
@export var bullets: Array[PackedScene]
@export_range(0.001, 60) var interval_between_shots: float = 0.4
@export var post_shot_cd_interval: float = 0.2

@export_group("Projectile Behavior", "projectile")
@export var projectile_homing: bool
@export var projectile_turn_rate_min: float = 0.0
@export var projectile_bounce: bool
@export var projectile_bounces_min: int = 1

@onready var post_shot_cooldown: Timer = $PostShotCooldown
@onready var cooldown_timer: Timer = $Cooldown

var direction: Vector2
var on_shoot_cooldown: bool
var is_animation_needed: bool = false:
	set(value):
		is_animation_needed = value
		if is_animation_needed and post_shot_cooldown:
			post_shot_cooldown.start(post_shot_cd_interval * shoot_ratio if 
			post_shot_cd_interval * shoot_ratio <= 0.5
			 else post_shot_cd_interval)
var can_shoot: bool = true
var shoot_ratio: float = 1.0


func _ready():
	_shoot_state_changed()


func _on_cooldown_ended():
	on_shoot_cooldown = false
	if is_shooting:
		_shoot()
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


func _shoot_state_changed():
	if is_shooting:
		_shoot()
		shooting_started.emit()
	else:
		shooting_stopped.emit()


func _shoot():
	if not is_inside_tree():
		return
	if not Game.bullets:
		await get_tree().process_frame
	if not Game.bullets:
		return
	
	if len(bullets) > 0:
		var bullet = bullets.pick_random().instantiate() as Bullet
		_apply_behavior(bullet)
		Game.bullets.add_child(bullet)
	
	is_animation_needed = true
	on_shoot_cooldown = true
	
	if cooldown_timer:
		cooldown_timer.start(interval_between_shots)
	
	post_shot_cd_started.emit()


func shoot():
	if on_shoot_cooldown or not enabled or not bullets or not can_shoot:
		return
	
	is_shooting = true


func stop_shooting():
	is_shooting = false


func set_bullet_array(array: Array[PackedScene]):
	bullets = array


func _on_post_shot_cooldown_timeout() -> void:
	is_animation_needed = false
	post_shot_cd_finished.emit()
