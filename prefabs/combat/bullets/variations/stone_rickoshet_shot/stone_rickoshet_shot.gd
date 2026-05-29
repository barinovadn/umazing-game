extends Bullet


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
	crit_chance = 1
	if vfx_bounce:
		vfx_bounce.spawn(global_position)
