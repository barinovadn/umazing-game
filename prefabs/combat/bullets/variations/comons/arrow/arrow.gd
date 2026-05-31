extends Bullet


func _on_area_entered(area: Area2D):
	if not _can_damage_team(area.team):
		return
	if area is HurtComponent:
		_crashed_into_hurt_component(area)
		area.take_damage(_calc_damage(area))
		return
	if area is Bullet:
		if can_be_broken and area.can_break:
			destroy()
		return


func _crashed_into_hurt_component(hurt_component: HurtComponent):
	hit.emit(hurt_component)
	if vfx_hit:
		vfx_hit.spawn(hurt_component.global_position)
	_crashed_in_char = true
	audio_player.stream = null
	audio_player.stop()
	_play_random_sound(sounds_hit)
