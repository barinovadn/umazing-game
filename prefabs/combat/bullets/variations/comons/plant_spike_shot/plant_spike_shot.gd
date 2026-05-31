@icon("bullet.png")
extends Bullet
class_name SineWaveBullet

@export_group("Sine Wave")
@export var base_amplitude: float = 0.0
@export var amplitude_growth: float = 50.0
@export var frequency: float = 15.0

var _time_passed: float = 0.0
var _current_offset: Vector2 = Vector2.ZERO


func _move(delta: float):
	position -= _current_offset
	
	super(delta)
	
	if is_deleted:
		return
	
	_time_passed += delta
	var current_amplitude = base_amplitude + (amplitude_growth * _time_passed)
	var wave_value = sin(_time_passed * frequency) * current_amplitude
	
	_current_offset = direction.orthogonal() * wave_value
	
	position += _current_offset
