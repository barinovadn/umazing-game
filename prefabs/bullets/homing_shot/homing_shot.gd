extends Bullet


func _ready() -> void:
	animated_sprite_2d.play("homing_shot")


func _process(delta: float) -> void:
	if target and auto_aim:
		direction = (target.global_position - animated_sprite_2d.global_position).normalized()
	_move(delta)


func _on_timer_timeout() -> void:
	auto_aim = false
