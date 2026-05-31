extends Bullet


@export var bullet_mini: PackedScene
@export var interval_between_spawn: float = 1.0

@onready var timer: Timer = $Timer

func _bullet_ready():
	timer.start()


func _on_timer_timeout():
	if not is_deleted:
		var bullet1 = bullet_mini.instantiate() as Bullet
		var bullet2 = bullet_mini.instantiate() as Bullet
		
		bullet1.homing = false
		bullet2.homing = false
		
		bullet1.direction = (direction + Vector2(0.5, 0.5)).normalized()
		bullet2.direction = (direction - Vector2(0.5, 0.5)).normalized()
		
		bullet1.global_position = global_position
		bullet2.global_position = global_position
		
		Game.bullets.add_child(bullet1)
		Game.bullets.add_child(bullet2)
		
		bullet1.audio_player.volume_db = audio_player.volume_db
		bullet2.audio_player.volume_db = audio_player.volume_db


func bounce(body: Node2D):
	var normal = shape_cast_2d.get_collision_normal(0)
	if not normal:
		direction *= -1
		bounced.emit(body, normal)
		_play_random_sound(sounds_bounce)
		if vfx_bounce:
			vfx_bounce.spawn(global_position)
		return
	_play_random_sound(sounds_bounce)
	direction = direction.bounce(normal)
	bounced.emit(body, normal)
	if vfx_bounce:
		vfx_bounce.spawn(global_position)
	timer.stop()
