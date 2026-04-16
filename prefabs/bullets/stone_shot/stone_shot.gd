extends Bullet


func _ready() -> void:
	animated_sprite_2d.play("stone_shot")
	# FIXME Base bullet logic?
	# Otherwise bullet.target usless without auto_aim set to true
	if target:
		direction = (target.global_position - animated_sprite_2d.global_position).normalized()
