extends Area2D
class_name Bullet

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export_group("Bullets")
## Крит. урон снаряда
@export var crit_damage : int:
	set(value):
			crit_damage = value
			if crit_damage >= damage * 3:
				crit_damage = damage
# Шанс нанести крит. урон
@export var crit_chance: float:
	set(value):
			crit_chance = value
			if crit_chance >= 1:
				crit_chance = 1

# Урон снаряда
@export var damage : int = 1
# Скорость снаряда
@export var speed : int = 100
# Направление полета снаряда
var direction: Vector2
@export var team: CombatScript.team:
	set(value):
		team = value

@export var auto_aim : bool = false
@export var target: Node2D

func _process(delta: float) -> void:
	_move(delta)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _destroy_bullet():
	queue_free()


## Обработка столкновений с hurt_component
func _on_area_entered(area: Area2D) -> void:
	if not area is HurtComponent:
		return
	if ((team == CombatScript.team.enemy and area.team == CombatScript.team.player) 
	or (team == CombatScript.team.player and area.team == CombatScript.team.enemy)):
		area.take_damage(self)
		_destroy_bullet()

func _move(delta : float) -> void:
	position += direction * speed * delta


## Столкновение с объектами на мапе
func _on_body_entered(_body: Node2D) -> void:
		_destroy_bullet()
