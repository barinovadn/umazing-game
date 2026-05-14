extends Bullet


func _on_map_collision(_body: Node2D):
	if speed >= 40:
		speed -= 30
		if speed < 40:
			speed = 40
	if bounces > 0:
		bounce(_body)
		bounces -= 1
	else:
		destroy()

func bounce(_body: Node2D):
	_play_random_sound(sounds_bounce)
	
	direction = _get_direction_to_target()
	
	if vfx_bounce:
		vfx_bounce.spawn(global_position)
