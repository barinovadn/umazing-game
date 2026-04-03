@icon("pixel_hurt.png")
class_name HurtComponent
extends Area2D

## Область урона игрока.Отвечает за получение урона от HitComponent снаряда
signal fatal_damage_taken
signal damaged

@export var team : CombatScript.team

@export var health = 20
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func take_damage(hit_component : Bullet) -> void:
	var total_damage : int = 0
	total_damage += hit_component.damage
	
	var chance_to_crit : float = randf_range(0, 1)
	
	if chance_to_crit <= hit_component.crit_chance:
		total_damage += hit_component.crit_damage
		
	health-=total_damage
	
	if health <= 0:
		fatal_damage_taken.emit()
	else:
		damaged.emit()
