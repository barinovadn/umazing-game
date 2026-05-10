@icon("hurt_component.png")
class_name HurtComponent
extends Area2D


signal fatal_damage_taken
signal damaged(by_amount: float)
signal healed(by_amount: float)
signal health_changed(by_amount: float)
signal max_health_changed

enum Team {
	NEUTRAL = 2,
	PLAYER = 1,
	ENEMY = 0,
	}

@export_group("Health")
@export var team: Team
@export var max_health: float = 1.0:
	set(value):
		var ratio: float = value / max_health
		max_health = value
		if current_health:
			current_health = (ratio * current_health)
		max_health_changed.emit()

@export_group("Sounds", "sounds")
@export var sounds_player: AudioStreamPlayer2D
@export var sounds_damage: Array[AudioStream] = []
@export var sounds_die: Array[AudioStream] = []
@export var sounds_heal: Array[AudioStream] = []
@export var sounds_volume_db: float:
	set(value):
		sounds_volume_db = value
		if is_node_ready() and sounds_player != null:
			sounds_player.volume_db = value

var current_health: float:
	set(value):
		var flag: int
		if value < current_health:
			flag = 1
		elif value > current_health:
			flag = 2
		
		var _previous_health := current_health
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
		sounds_player.volume_db = sounds_volume_db


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
