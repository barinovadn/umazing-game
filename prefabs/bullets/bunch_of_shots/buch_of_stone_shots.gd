extends Bullet

const bullet_type = preload("uid://bx0aayot7ndhr")

@export var amount_of_bullets: int = 5
@export var spacing: float = 44:
	set(value):
		pass
@export var offset_from_center: float = 10

func _ready():
	var dir = _get_direction()
	var perp = Vector2(-dir.y, dir.x) # перпендикуляр

	# точка, откуда строится линия (чуть впереди)
	var base_pos = global_position + dir * offset_from_center

	# центрируем линию относительно base_pos
	var half = (amount_of_bullets - 1) / 2.0

	for i in amount_of_bullets:
		var bullet = bullet_type.instantiate() as Bullet

		var offset = (i - half) * spacing
		var spawn_pos = base_pos + perp * offset

		bullet.global_position = spawn_pos
		_copy_arguments(bullet, dir)

		get_node("/root/Game/%Bullets").add_child(bullet)
		bullet.bullet_sound_player.volume = bullet_sound_player.volume

	_destroy_bullet()

func  _process(_delta: float) -> void:
	pass

func _get_direction() -> Vector2:
	if target:
		return (target.global_position - global_position).normalized()
	return direction.normalized()


func _copy_arguments(bullet: Bullet, dir : Vector2):
	bullet.can_be_broken = can_be_broken
	bullet.can_brake = can_brake
	bullet.can_recochete = can_recochete
	bullet.number_of_recochets = number_of_recochets
	# если у пули есть направление — передаём
	if bullet.has_method("set_direction"):
		bullet.set_direction(dir)
	elif "direction" in bullet:
		bullet.direction = dir
