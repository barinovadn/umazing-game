class_name HitComponent

## Перегрузка класса для пули, чтобы было удобнее фиксировать урон
## Каждая пуля должна быть расширением данного класса

extends Area2D

## Урон снаряда
@export var hit_damage : int = 1
