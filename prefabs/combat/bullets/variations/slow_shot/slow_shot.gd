extends Bullet

@export var modification: Modification

func _crashed_into_hurt_component(hurt_component: HurtComponent):
	hit.emit(hurt_component)
	hurt_component.character.apply_speed_modifier(modification)
	if vfx_hit:
		vfx_hit.spawn(hurt_component.global_position)
	_crashed_in_char = true
	audio_player.stream = null
	audio_player.stop()
	_play_random_sound(sounds_hit)
