extends Bullet
@onready var timer: Timer = $Timer

func _on_timer_timeout() -> void:
	auto_aim = false
