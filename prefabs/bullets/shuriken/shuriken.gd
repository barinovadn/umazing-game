extends Bullet


func _ready() -> void:
	animated_sprite_2d.play("player_shot")
	sound_player.play_random_sound()
	

func _process(delta: float) -> void:
	if target and auto_aim:
		direction = (target.global_position - animated_sprite_2d.global_position).normalized()
	_move(delta)
