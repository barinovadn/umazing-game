extends Bullet


func _ready() -> void:
	animated_sprite_2d.play("stone_shot")
	if target:
		direction = (target.global_position - animated_sprite_2d.global_position).normalized()
