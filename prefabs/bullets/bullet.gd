extends Area2D
class_name Bullet

signal hitted
signal crit_damage_delt
signal destroyed

@export_group("Movement")
@export var speed: int = 100

## The vector that determines the direction in which the bullet will fly
## if [member auto_aim] is not enabled
@export var direction: Vector2

## The component that the bullet will be aimed at if [member auto_aim] is enabled
@export var target: Node2D
## Determines whether the bullet's auto-targeting feature is enabled
@export var auto_aim : bool = false:
	set(value):
		print(value)
		auto_aim = value

## The possibility of a bullet ricocheting off a body on the Map collision layer
@export var can_ricochet: bool = false
## The number of times the bullet ricochets off the surface
@export var number_of_recochets_left: int = INF:
	set(value):
		number_of_recochets_left = value
		if number_of_recochets_left <= 0:
			can_ricochet = false

@export_group("Damage")
@export var damage: int = 1
@export var team: HurtComponent.HurtComponentTeam

## Additional damage that has a [member crit_chance] to be added to the base damage
@export var crit_damage: int
## A chance to deal additional damage
@export_range(0.0, 1.0) var crit_chance: float

@export_group("Destruction")
@export var can_be_broken : bool = false
@export var can_break: bool = false

@export_group("Sounds", "sounds")
@export var sounds_spawn: Array[AudioStream] = []
@export var sounds_die: Array[AudioStream] = []
@export var sounds_hit: Array[AudioStream] = []
@export var sounds_alive: Array[AudioStream] = []
@export var sounds_rikoshet: Array[AudioStream] = []

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var shape_cast_2d: ShapeCast2D = $ShapeCast2D


func _bullet_ready(): pass


func _ready():
	shape_cast_2d.shape = collision_shape_2d.shape
	animated_sprite_2d.play("shot")
	
	if sounds_spawn:
		audio_player.stream = sounds_spawn.pick_random()
		audio_player.play()
	_bullet_ready()


func _process(delta: float) -> void:
	_move(delta)


func _on_not_visible() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.team == team:
		return
	
	if area is HurtComponent:
		area.take_damage(_calc_damage())
		destroy()
		return
	
	if area is Bullet:
		if can_be_broken and area.can_break:
			destroy()
		return


func _calc_damage() -> int:
	var amount := damage
	
	if randf_range(0, 1) <= crit_chance:
		amount += crit_damage
	
	return amount


func _move(delta : float) -> void:
	if auto_aim and target:
		direction = _get_direction_to_target()
	position += direction * speed * delta


func _on_map_collision(_body: Node2D) -> void:
	print('Я погнал')
	if can_ricochet:
		ricochet(_body)
		number_of_recochets_left -= 1
	else:
		destroy()


func ricochet(body: Node2D) -> void:
	print('Я погнал')
	#shape_cast_2d.shape = collision_shape_2d.shape
	var normal = shape_cast_2d.get_collision_normal(0)
	
	if not normal:
		print('Нихуя тут нет')
		_move(-get_process_delta_time())
		direction *= -1
		return
	
	_move(-get_process_delta_time())
	direction = direction.bounce(normal)



func destroy() -> void:
	visible = false
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(queue_free)


func _get_direction_to_target() -> Vector2:
	return (target.global_position - animated_sprite_2d.global_position).normalized()
