@icon("shoot_controller.png")
class_name ShootController
extends Node2D


signal shooting_started()
signal shooting_stopped()

@export var team := HurtComponent.Team.NEUTRAL
@export var auto_aim: bool
@export var bullets: Array[PackedScene]
@export_range(0.001, 60) var interval_between_shots: float = 0.1
@export var enabled: bool = true

@export_group("Projectile Behavior", "projectile")
@export var projectile_homing: bool
@export var projectile_homing_target: Node2D
@export var projectile_turn_rate_min: float = 0.0
@export var projectile_bounce: bool
@export var projectile_bounces_min: int = 1
 
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
		else:
			shooting_stopped.emit()


func _on_cooldown_ended():
	is_shooting = false


func _direction_to(target: Node2D) -> Vector2:
	if not target:
		return Vector2.ZERO
	return (target.global_position - global_position).normalized()


func _set_bullet_direction(bullet: Bullet):
	if auto_aim:
		bullet.direction = _direction_to(get_closest_target())
		return
	
	bullet.direction = direction


func _apply_behavior(bullet: Bullet):
	if projectile_homing:
		bullet.homing = true
		bullet.target = ( projectile_homing_target if projectile_homing_target
			else get_closest_target() )
	
	if projectile_bounce:
		bullet.bounces = max(bullet.bounces, bullet.bounces)
	
	bullet.turn_rate = max(bullet.turn_rate, projectile_turn_rate_min)


func get_closest_target() -> HurtComponent:
	if not is_inside_tree():
		return null
	
	var targets = get_tree().get_nodes_in_group("hurt_component")
	var closest = null
	var closest_dist = INF

	for target in targets:
		if target.team == team:
			continue
		
		var target_pos = target.global_position
		var dist = global_position.distance_to(target_pos)
		
		if dist < closest_dist:
			closest_dist = dist
			closest = target

	return closest


func shoot(bullet_scene: PackedScene = null):
	if is_shooting or not enabled:
		return
	
	is_shooting = true
	var bullet: Bullet
	
	if bullet_scene:
		bullet = bullet_scene.instantiate() as Bullet
	else:
		bullet = bullets.pick_random().instantiate() as Bullet
	
	bullet.team = team
	bullet.global_position = global_position
	
	_set_bullet_direction(bullet)
	_apply_behavior(bullet)
	
	Game.bullets.add_child(bullet)
