class_name ActionsUI
extends Control


@export var speedrun_timer_includes_ms: bool = true

@export_group("Sounds", "sound")
@export var sound_timer_click: AudioStream = preload("res://prefabs/combat/sounds/bounce_1.wav")

@onready var _timer: Timer = %SpeedrunTimer
@onready var _timer_label: Label = %TimerLabel
@onready var _audio_player: AudioStreamPlayer = %AudioPlayer

var total_playtime: float = 0.0


func _formatted_playtime(playtime: float, include_ms: bool = false) -> String:
	var total_seconds: int = int(playtime)
	@warning_ignore("integer_division")
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	
	if include_ms:
		var milliseconds: int = int((playtime - total_seconds) * 100)
		return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
		
	return "%02d:%02d" % [minutes, seconds]


func _on_timer_tick():
	total_playtime += _timer.wait_time
	
	if _timer_label.visible:
		_timer_label.text = _formatted_playtime(total_playtime,
			speedrun_timer_includes_ms)


func _on_book_button_up():
	pass


func _on_inventory_pressed():
	if Game.player.inventory_ui.visible:
		Game.player.inventory_ui.close()
	else:
		Game.player.inventory_ui.open()


func _on_timer_pressed():
	_timer_label.visible = !_timer_label.visible
	if sound_timer_click:
		play_sound(sound_timer_click)


func play_sound(sound: AudioStream):
	if not _audio_player or not sound:
		return
	
	_audio_player.stream = sound
	_audio_player.play()
