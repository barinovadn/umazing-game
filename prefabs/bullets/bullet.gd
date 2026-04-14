extends Area2D
class_name Bullet

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

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

@export var can_be_broken : bool = false
@export var can_brake: bool = false

@export var auto_aim : bool = false
@export var target: Node2D
@export var can_recochete: bool = false
@export var number_of_recochets: int = 0

func _process(delta: float) -> void:
	_move(delta)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _destroy_bullet():
	visible = false
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(queue_free)


## Обработка столкновений с hurt_component и Bullet
func _on_area_entered(area: Area2D) -> void:
	if not area is HurtComponent and not area is Bullet:
		return
		
	if area is Bullet && area.team != team:
		# Пульки сталкиваются, только если у обоих включено столкновение
		if can_be_broken and area.can_brake:
			_destroy_bullet()
	elif area is HurtComponent:
		if ((team == CombatScript.team.enemy and area.team == CombatScript.team.player) 
		or (team == CombatScript.team.player and area.team == CombatScript.team.enemy)):
			area.take_damage(self)
			_destroy_bullet()

func _move(delta : float) -> void:
	position += direction * speed * delta


## Столкновение с объектами на мапе, если включён рикошет, будет отскакивать от стенок
func _on_body_entered(_body: Node2D) -> void:
	if can_recochete and number_of_recochets > 0:
		number_of_recochets -= 1
		if number_of_recochets <= 0:
			can_recochete = false
		reverse_direction()
	else:
		_destroy_bullet()
 
func reverse_direction():
		direction*=-1
