extends AudioStreamPlayer
class_name BulletSoundPlayer

@export var bullet_appearence_sounds: Array[AudioStream] = []

@export var volume: float = -4.0:
	set(value):
		volume_db = value
		volume = value

func play_random_appearence_sound():
	if bullet_appearence_sounds.size():
		stream = bullet_appearence_sounds.pick_random()
		play()
