@icon("bullet.png")
extends Area2D
class_name Bullet


signal hit(hurt_component: HurtComponent)
signal bounced(body: Node2D, normal: Vector2)
signal crit
signal destroyed
signal deleted

@export_group("Movement")
@export var speed: float = 100
## The bullet's angular velocity relative to the target, in degrees per second
@export var turn_rate: float = 45.0
## The vector that determines the direction in which the bullet will fly
## if [member homing] is not enabled
@export var direction: Vector2
## The number of times the bullet bounces off the surface
@export var bounces: int = 0
@export_subgroup("Homing")
## Determines whether the bullet's auto-targeting feature is enabled
@export var homing: bool = false
## The node that the bullet will be aimed at if [member homing] is enabled
@export var target: Node2D

@export_group("Damage")
@export var damage: float = 1.0
@export var team: HurtComponent.Team
## Additional damage that has a [member crit_chance] to be added to the base damage
@export var crit_damage: float
## A chance to deal additional damage
@export_range(0.0, 1.0) var crit_chance: float

@export_group("Destruction")
@export var can_be_broken: bool = false
@export var can_break: bool = false
@export var lifespan: float = 0.0

@export_group("Sounds", "sounds")
@export var sounds_spawn: Array[AudioStream] = []
@export var sounds_destroy: Array[AudioStream] = []
@export var sounds_hit: Array[AudioStream] = []
@export var sounds_alive: Array[AudioStream] = []
@export var sounds_bounce: Array[AudioStream] = []

@export_group("Afterlife", "afterlife")
@export var afterlife_duration: float = 7.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var shape_cast_2d: ShapeCast2D = $ShapeCast2D

## A variable that indicates whether deferred deletion is enabled for the bullet
var is_deleted: bool = false
var _crashed_in_char: bool = false


func _bullet_ready(): pass
func _bullet_process(): pass


func _ready():
	if collision_shape_2d.shape:
		shape_cast_2d.shape = collision_shape_2d.shape
	else:
		shape_cast_2d.enabled = false
	_play_random_sound(sounds_spawn)
	play_sound_being_alive(sounds_alive)
	if lifespan > 0:
		var timer = get_tree().create_timer(lifespan)
		timer.timeout.connect(destroy)
	_bullet_ready() 


func _process(delta: float):
	_move(delta)
	_bullet_process()


func _on_area_entered(area: Area2D):
	if area.team == team:
		return
	if area is HurtComponent:
		_crashed_into_hurt_component(area)
		area.take_damage(_calc_damage())
		destroy()
		return
	if area is Bullet:
		if can_be_broken and area.can_break:
			destroy()
		return


func _play_random_sound(array: Array[AudioStream]):
	if array.size():
		audio_player.stream = array.pick_random()
		audio_player.play()


func _crashed_into_hurt_component(hurt_component: HurtComponent):
	hit.emit(hurt_component)
	_crashed_in_char = true
	audio_player.stream = null
	audio_player.stop()
	_play_random_sound(sounds_hit)


func _calc_damage() -> float:
	var amount := damage
	if randf_range(0, 1) <= crit_chance:
		crit.emit()
		amount += crit_damage
	return amount


func _move(delta: float):
	if homing and target and is_instance_valid(target):
		if !direction:
			direction = _get_direction_to_target()
		var target_dir = _get_direction_to_target()
		var angle_diff = direction.angle_to(target_dir)
		var max_rotation_this_frame = deg_to_rad(turn_rate) * delta
		var rotation_step = sign(angle_diff) * min(abs(angle_diff), max_rotation_this_frame)
		direction = direction.rotated(rotation_step)
	rotation = direction.angle()
	position += direction * speed * delta


func _on_map_collision(_body: Node2D):
	if bounces > 0:
		bounce(_body)
		bounces -= 1
	else:
		destroy()


## If there is a sound effect when removing a bullet, play it.
## The bullet will be removed after the last sound effect ends.
func _delete():
	queue_free()
	deleted.emit()


func _get_direction_to_target() -> Vector2:
	if not target:
		return direction
	return (target.global_position - animated_sprite_2d.global_position).normalized()


func bounce(body: Node2D):
	var normal = shape_cast_2d.get_collision_normal(0)
	if not normal:
		direction *= -1
		return
	_play_random_sound(sounds_bounce)
	direction = direction.bounce(normal)
	bounced.emit(body, normal)


func destroy():
	if is_deleted:
		return
	is_deleted = true
	destroyed.emit()
	stop_and_disable_interaction()
	if !_crashed_in_char:
		audio_player.stream = null
		audio_player.stop()
		_play_random_sound(sounds_destroy)
	var timer = get_tree().create_timer(afterlife_duration)
	timer.timeout.connect(_delete)


func play_sound_being_alive(array: Array[AudioStream]):
	if not array.size() or is_deleted:
		return
	
	await audio_player.finished
	
	audio_player.stream = array.pick_random()
	audio_player.play()


func stop_and_disable_interaction():
	speed = 0
	visible = false
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
