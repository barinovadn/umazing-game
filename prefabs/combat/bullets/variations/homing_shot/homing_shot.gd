extends Bullet

@export var homing_time: float = 10.0

func _bullet_ready():
	var tween = create_tween()
	tween.tween_property(self, "turn_rate", 0.0, homing_time)

 
