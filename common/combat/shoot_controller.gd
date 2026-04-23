@icon("boxer_gloves.png")
class_name ShootController
extends Node2D

## Signal activation plays the shooting animation on the character
signal shooting_started()
## Signal activation stops the shooting animation on the character
signal shooting_stopped()

@onready var timer: Timer = $Timer

@export_group("Projectile behavior")
@export var team : HurtComponent.Team
@export var is_homing_on : bool = false
@export var is_bounce_on: bool = false
@export var number_of_bounces: int

@export_group("Shoot controller behavior")
@export var bullet_types: Array[Resource] 
@export var interval_between_shots: float
@export var can_shoot: bool = false


var direction : Vector2
## Indicates whether the component is in firing mode
## (is waiting for the post-firing delay)
var is_shooting : bool = false:
	set(value):
		if value == is_shooting:
			return
		is_shooting = value
		if is_shooting:
			timer.start()
			shooting_started.emit()
		else:
			shooting_stopped.emit()

func _get_direction_to_object(target: Node2D) -> Vector2:
	return (target.global_position - global_position).normalized()

func _on_timer_timeout() -> void:
	is_shooting = false

func create_a_projectile_from_argument(bullet: Resource = null) -> void:
	if is_shooting or !can_shoot:
		return
	var projectile : Bullet
	if !bullet:
		projectile = bullet_types.pick_random().instantiate() as Bullet
	else:
		projectile = bullet.instantiate() as Bullet
	if is_homing_on:
		var target = get_closest_target()
		projectile.direction = _get_direction_to_object(target)
		projectile.target = target
	else :
		projectile.direction = direction
	if is_bounce_on:
		projectile.can_ricochet = true
		projectile.number_of_recochets_left = number_of_bounces
	
	projectile.team = team
	projectile.global_position = global_position
	timer.wait_time = interval_between_shots
	is_shooting = true
	get_node("/root/Game/%Bullets").add_child(projectile)

func get_closest_target():
	var targets = get_tree().get_nodes_in_group("hurt_components")
	
	var closest = null
	var closest_dist = INF

	for t in targets:
		if t.team == team:
			continue  # пропускаем своих
		
		var target_pos = t.global_position
		var dist = global_position.distance_to(target_pos)

		if dist < closest_dist:
			closest_dist = dist
			closest = t

	return closest
