@icon("pixel_hurt.png")
class_name HurtComponent
extends Area2D

## Область урона игрока.Отвечает за получение урона от HitComponent снаряда
signal fatal_damage_taken
signal damaged

enum HurtComponentTeam {
	enemy = 0,
	player = 1,
	neutral = 2
}

@export var team : HurtComponentTeam
@export var max_health = 20

var _total_damage : int = 0
var current_health : int  :
	get():
		return max_health - _total_damage
	set(value):
		_total_damage = (max_health - value)
		if max_health - _total_damage <= 0:
			_disabling()
			fatal_damage_taken.emit()
		else:
			damaged.emit()

#func take_damage(hit_component: Bullet) -> void:
	#var damage : int = 0
	#damage += hit_component.damage
	#
	#var chance_to_crit : float = randf_range(0, 1)
	#
	#if chance_to_crit <= hit_component.crit_chance:
		#damage += hit_component.crit_damage
		#
	#current_health-=damage

func take_damage(amount: int = 0):
	current_health -= amount


func _disabling():
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
