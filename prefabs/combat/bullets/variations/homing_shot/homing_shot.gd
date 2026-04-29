extends Bullet

@export var auto_aim_time: float = 10.0

func _bullet_ready():
	var tween = create_tween()
	tween.tween_property(self, "turn_speed_degrees", 0.0, auto_aim_time)
 
