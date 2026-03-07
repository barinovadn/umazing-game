class_name EnemyHurtComponent
extends Area2D

## Вражеская область урона.Отвечает за получение урона от HitComponent снаряда

signal died
signal damaged

@export var heath = 20

## Фиксирует попадание от снаряда
func _on_area_entered(area: Area2D) -> void:
	var hit_component = area as HitComponent
	if hit_component:
		heath -= hit_component.hit_damage
		if heath<=0:
			died.emit()
		else:
			damaged.emit()
