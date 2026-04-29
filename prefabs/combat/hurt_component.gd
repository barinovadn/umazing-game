@icon("hurt_component.png")
class_name HurtComponent
extends Area2D


signal fatal_damage_taken
signal damaged(by_amount: float)        
signal healed(by_amount: float)         
signal health_changed(by_amount: float) 

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
@export var sounds_volume: float:
	set(value):
		sounds_volume = value
		if is_node_ready() and sounds_player != null:
			sounds_player.volume_db = value

@export_group("Health")
@export var team: Team
@export var max_health: float = 20.0

var _total_damage: float = 0.0
var current_health: float:
	get():
		return max_health - _total_damage
	set(value):
		var previous_health = max_health - _total_damage
		_total_damage = (max_health - value)
		health_changed.emit(value - previous_health) 
		
		if max_health - _total_damage <= 0:
			_disable()
			_play_random_sound(sounds_die)
			fatal_damage_taken.emit()
		else:
			_play_random_sound(sounds_damage)


func _ready():
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
