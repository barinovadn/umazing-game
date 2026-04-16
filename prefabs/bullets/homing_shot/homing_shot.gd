extends Bullet


func _ready() -> void:
	animated_sprite_2d.play("homing_shot")
	bullet_sound_player.play_random_appearence_sound()

var previous_direction = Vector2.RIGHT

func _process(delta: float) -> void:
	if target and auto_aim:
		direction = (target.global_position - animated_sprite_2d.global_position).normalized()
		previous_direction = direction
	if !target:
		direction = previous_direction
	_move(delta)


func _on_timer_timeout() -> void:
	auto_aim = false
