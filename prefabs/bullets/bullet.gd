extends Area2D
class_name Bullet

signal direction_needed

@export_group("Bullets")
## Урон снаряда
@export var crit_damage : int:
	set(value):
			crit_damage = value
			if crit_damage >= damage * 3:
				crit_damage = damage
@export var crit_chance: float:
	set(value):
			crit_chance = value
			if crit_chance >= 1:
				crit_chance = 1
@export var damage : int = 1
@export var speed : int = 100
@export var bullet_enemy : Character2D

var direction = null
var team: CombatScript.team:
	set(value):
		pass
		

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _destroy_bullet():
	queue_free()

func _set_enemy():
	pass

## Collision with hp components
func _on_area_entered(area: Area2D) -> void:
	if area is HurtComponent:
		#print(team)
		#print(area.team)
		if (team == CombatScript.team.enemy and area.team == CombatScript.team.player) or (team == CombatScript.team.player and area.team == CombatScript.team.enemy):
			area.take_damage(self)
			_destroy_bullet()

## Target collision with objects on the map
func _on_body_entered(body: Node2D) -> void:
		_destroy_bullet()
