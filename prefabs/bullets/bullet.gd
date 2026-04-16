extends Area2D
class_name Bullet


# Signals
# - Crit?
# - Hit
# - Destroyed

# Sounds
# On spawn
# On die
# On hit?
# On alive/live

@export_group("Movement")
@export var speed: int = 100

# TODO Unclear logic, need docs?
@export var direction: Vector2

# TODO Unclear logic, need docs?
@export var target: Node2D
# TODO Unclear logic, need docs?
@export var auto_aim : bool = false

# TODO Unclear logic, need docs?
@export var can_ricochet: bool = false
# TODO Unclear logic, need docs?
@export var number_of_recochets: int = INF:
	set(value):
		number_of_recochets = value
		if number_of_recochets <= 0:
			can_ricochet = false

@export_group("Damage")
@export var damage: int = 1
@export var team: CombatScript.team

# TODO Unclear logic, need docs?
@export var crit_damage: int
@export_range(0.0, 1.0) var crit_chance: float

@export_group("Destruction")
@export var can_be_broken : bool = false
@export var can_break: bool = false

@export_group("Sounds", "sounds")
@export var sounds_spawn: Array[AudioStream] = []

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
#@onready var bullet_sound_player: BulletSoundPlayer = $BulletSoundPlayer


func _bullet_ready(): pass


func _ready():
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
	position += direction * speed * delta
	
	if auto_aim:
		pass # FIXME Dead flag


func _on_map_collision(_body: Node2D) -> void:
	if can_ricochet and number_of_recochets > 0:
		ricochet(_body)
		number_of_recochets -= 1
	else:
		destroy()
 

func ricochet(_surface: Node2D) -> void:
	direction *= -1


func destroy() -> void:
	visible = false
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(queue_free)
