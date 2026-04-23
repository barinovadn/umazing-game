@icon("pixel_hurt.png")
class_name HurtComponent
extends Area2D

signal fatal_damage_taken
signal damaged

@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer

## Specifies the team to which the parent belongs. 
enum HurtComponentTeam {
	enemy = 0,
	player = 1,
	neutral = 2
}

@export_group("Sounds")
@export var damage_sounds: Array[AudioStream] = []
@export var die_sound: AudioStream = null
@export_group("Sounds")
@export var team : HurtComponentTeam
@export var max_health = 20

var _total_damage : int = 0
var current_health : int  :
	get():
		return max_health - _total_damage
	set(value):
		_total_damage = (max_health - value)
		if max_health - _total_damage <= 0:
			_disabling()
			if die_sound:
				audio_player.stream = die_sound
				audio_player.play()
			fatal_damage_taken.emit()
		else:
			play_random_sound(damage_sounds)
			damaged.emit()


func take_damage(amount: int = 0):
	current_health -= amount


func play_random_sound(array: Array[AudioStream]):
	if array.size():
		audio_player.stream = array.pick_random()
		audio_player.play()


func _disabling():
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
