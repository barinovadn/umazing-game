@icon("hurt_component.png")
class_name HurtComponent
extends Area2D


signal fatal_damage_taken
signal damaged(by_amount: float)
signal healed(by_amount: float)
signal health_changed(by_amount: float)
signal max_health_changed

## Specifies the team to which the parent belongs. 
enum Team {
	enemy = 0,
	player = 1,
	neutral = 2,
}

@export_group("Sounds", "sounds")
@export var sounds_player: AudioStreamPlayer2D
@export var sounds_damage: Array[AudioStream] = []
@export var sounds_die: Array[AudioStream] = []
@export var sounds_heal: Array[AudioStream] = []
@export var sounds_volume: float:
	set(value):
		sounds_volume = value
		if is_node_ready() and sounds_player != null:
			sounds_player.volume_db = value

@export_group("Health")
@export var team: Team
@export var max_health: float = 20.0:
	set(value):
		var koef: float = value / max_health
		if current_health:
			current_health = (koef * current_health)
		max_health = value
		max_health_changed.emit()


var _previous_health: float = 0.0
var current_health: float:
	set(value):
		var flag: int
		if value < current_health:
			flag = 1
		elif value > current_health:
			flag = 2
		
		current_health = value
		health_changed.emit(value - _previous_health) 
		
		if flag == 1:
			damaged.emit(abs(_previous_health - current_health))
			_play_random_sound(sounds_damage)
		elif flag == 2:
			healed.emit(abs(_previous_health - current_health))
			_play_random_sound(sounds_heal)
		
		if current_health<= 0:
			_disable()
			_play_random_sound(sounds_die)
			fatal_damage_taken.emit()
		_previous_health = current_health


func _ready():
	current_health = max_health
	if sounds_player != null:
		sounds_player.volume_db = sounds_volume


func _play_random_sound(array: Array[AudioStream]):
	if array.size():
		sounds_player.stream = array.pick_random()
		sounds_player.play()


func _disable():
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)


func take_damage(amount: float = 0):
	damaged.emit(amount)
	current_health -= amount


func heal(amount: float = 0):
	healed.emit(amount)
	current_health += amount
