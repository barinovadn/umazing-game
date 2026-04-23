extends Area2D
class_name Bullet

## Crashed into [HurtComponent]
signal hit
## Critical damage was dealt
signal crit_damage_delt
## Scheduled deletion has been initiated
signal deletion_initiated
## Bullet removal complete
signal deletion_completed

@export_group("Movement")
@export var speed: float = 100
## The vector that determines the direction in which the bullet will fly
## if [member auto_aim] is not enabled
@export var direction: Vector2
## The node that the bullet will be aimed at if [member auto_aim] is enabled
@export var target: Node2D
## Determines whether the bullet's auto-targeting feature is enabled
@export var auto_aim : bool = false:
	set(value):
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
@export var damage: float = 1.0
@export var team: HurtComponent.Team
## Additional damage that has a [member crit_chance] to be added to the base damage
@export var crit_damage: float
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
@export var sounds_ricochet: Array[AudioStream] = []

@export_group("Animations", "animation")
@export var animation_start: String = "shot"

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var shape_cast_2d: ShapeCast2D = $ShapeCast2D

## A variable that indicates whether deferred deletion is enabled for the bullet
var is_deleted_with_delay: bool = false


func _bullet_ready(): pass


func _ready():
	if collision_shape_2d.shape:
		shape_cast_2d.shape = collision_shape_2d.shape
	else:
		shape_cast_2d.enabled = false
	if( animated_sprite_2d.sprite_frames
		and animated_sprite_2d.sprite_frames.has_animation(animation_start) ):
		animated_sprite_2d.play(animation_start)
	play_random_sound(sounds_spawn)
	play_sound_being_alive(sounds_alive)
	_bullet_ready() 


func _process(delta: float) -> void:
	_move(delta)


func _on_area_entered(area: Area2D) -> void:
	if area.team == team:
		return
	if area is HurtComponent:
		hit.emit()
		play_random_sound(sounds_hit)
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
		crit_damage_delt.emit()
		amount += crit_damage
	return amount


func _move(delta: float) -> void:
	if auto_aim and target:
		direction = _get_direction_to_target()
	position += direction * speed * delta


func _on_map_collision(_body: Node2D) -> void:
	if can_ricochet:
		ricochet(_body)
		number_of_recochets_left -= 1
	else:
		destroy()

## If there is a sound effect when removing a bullet, play it.
## The bullet will be removed after the last sound effect ends.
func _delete_object():
	await audio_player.finished
	queue_free()
	deletion_completed.emit()


func _get_direction_to_target() -> Vector2:
	return (target.global_position - animated_sprite_2d.global_position).normalized()


func ricochet(_body: Node2D) -> void:
	var normal = shape_cast_2d.get_collision_normal(0)
	if not normal:
		direction *= -1
		return
	play_random_sound(sounds_ricochet)
	direction = direction.bounce(normal)


func destroy() -> void:
	is_deleted_with_delay = true
	deletion_initiated.emit()
	stop_and_disable_interaction()
	audio_player.stream = null
	audio_player.stop()
	play_random_sound(sounds_die)
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(_delete_object)

## Loads a random sound from the array passed as an argument into the 2D audio stream player
func play_random_sound(array: Array[AudioStream]):
	if array.size():
		audio_player.stream = array.pick_random()
		audio_player.play()


func play_sound_being_alive(array: Array[AudioStream]):
	if not array.size() or is_deleted_with_delay:
		return
	
	await audio_player.finished
	
	audio_player.stream = array.pick_random()
	audio_player.play()


func stop_and_disable_interaction():
	speed = 0
	visible = false
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
