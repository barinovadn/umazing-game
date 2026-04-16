extends AudioStreamPlayer
class_name SoundPlayer

@export var hits_playlist: Array[AudioStream] = []

@export var volume: float = -4.0:
	set(value):
		volume_db = volume
		volume = value


func play_random_hit_sound():
	if hits_playlist.size():
		stream = hits_playlist.pick_random()
		play()
