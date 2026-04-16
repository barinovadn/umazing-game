extends AudioStreamPlayer
class_name BulletSoundPlayer

@export var bullet_appearence_sounds: Array[AudioStream] = []

func play_random_appearence_sound():
	if bullet_appearence_sounds.size():
		stream = bullet_appearence_sounds.pick_random()
		play()
