@icon("boxer_gloves.png")
class_name ShootController2D
extends Node2D

signal shooting_started()
signal shooting_stopped()

@export var bullet_types: Array[Resource] 
@export var fighting_enabled: bool = true:
	set(value):
		if fighting_enabled != value:
			fighting_enabled = value
@export var is_homing_on : bool = false
@export var team : HurtComponent.HurtComponentTeam
@export var is_bounce_on: bool = false
@export var number_of_bounces: int

var projectile : Bullet
var direction : Vector2
var is_shooting : bool = false:
	set(value):
		if value == is_shooting:
			return
		elif is_shooting && !fighting_enabled:
			return
		is_shooting = value
		if is_shooting:
			shooting_started.emit()
		else:
			shooting_stopped.emit()


func create_a_projectile_from_argument(bullet: Resource = null) -> void:
	if !fighting_enabled:
		return
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


func _get_direction_to_object(target: Node2D) -> Vector2:
	return (target.global_position - global_position).normalized()
