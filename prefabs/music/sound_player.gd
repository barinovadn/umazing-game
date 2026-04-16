extends AudioStreamPlayer
class_name SoundPlayer

@export var playlist: Array[AudioStream] = []
@export var volume: float = -4.0:
	set(value):
		volume_db = volume
		volume = value

func play_random_sound():
	if playlist.size():
		stream = playlist.pick_random()
		play()
