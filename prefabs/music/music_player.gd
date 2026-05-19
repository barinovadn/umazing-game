@icon("music_player.png")
class_name MusicPlayer
extends AudioStreamPlayer
## Simple background music player.


signal track_started ## A new track just started playing.
signal track_ended ## A track just ended.
signal break_ended ## A break just ended (see [member delay]).

enum State { IDLE, PLAYING, FADING, BREAK }
enum Order { SEQUENTIAL, SHUFFLE }
enum Delay { NONE, SHORT, NORMAL, LONG }

## List of [[member break_min], [member break_max]] type pairs for
## each [enum Delay]. Each pair represents the minimum and maximum break
## duration in seconds (see [member delay]). 
const BREAK_DURATIONS: Array[Array] = [
	[0.0, 0.0], [5.0, 10.0], [15.0, 20.0], [30.0, 60.0]
	]

## The current set of tracks to be [member auto]-played or controlled manually
## using [method play_track], [method next], [method back] ... .
## [br][br]NOTE: The [member playlist] should only be managed using the
## [method add_track] method or with a direct [code]playlist = [...][/code].
@export var playlist: Array[AudioStream] = []:
	set(value):
		playlist = value
		history = []
		_refill_shuffle_pool()
## Whether or not should auto-play next track whenever a track ends.
@export var auto: bool = true
## Order in which the tracks are played.
@export var order: Order = Order.SEQUENTIAL
## The delay/break between tracks when using [member auto] [code]true[/code] or
## [method fade_out]. See [member BREAK_DURATIONS] for min/max break durations.
@export var delay: Delay = Delay.NORMAL:
	set(value):
		delay = value
		break_min = BREAK_DURATIONS[delay][0]
		break_max = BREAK_DURATIONS[delay][1]
## Volume fade duration in seconds at the end of each track.
@export var fade: float = 3.0

var state: State = State.IDLE ## The state of the player.
var is_paused: bool = false: ## Whether the player is currently paused or not.
	set(value):
		is_paused = value
		
		stream_paused = is_paused
		break_timer.paused = is_paused
		
		match state:
			State.FADING:
				if _fade_out_tween and _fade_out_tween.is_valid():
					if is_paused:
						_fade_out_tween.pause()
					else:
						_fade_out_tween.play()
## Index of the currently playing/last played track from the [member playlist].
var playlist_index: int = -1
## Index history of the tracks played from [member playlist].
## Does not include the [member playlist_index].
## The elements are popped out from the back when using [method back].
## [br][br]NOTE: Erased whenever the [member playlist] is reset.
var history: Array[int] = []
var history_limit: int = 10 ## The maximum length of the [member history].
var break_min: float = 0.0 ## NOTE Updated whenever the [member delay] changs.
var break_max: float = 0.0 ## NOTE Updated whenever the [member delay] changs.
## A shuffled copy of [member playlist] used for [member Order.SHUFFLE].
## The elements are popped out from the back on [method next].
var shuffle_pool: Array[int] = []
var time_left: float: ## NOTE: Read-only.
	get():
		if not stream:
			return 0.0
		return stream.get_length() - get_playback_position()
var _base_volume_db: float
var _fade_out_tween: Tween

## Timer node used to count-down breaks between tracks (see [member delay]).
@onready var break_timer: Timer = $Break


func _ready():
	delay = delay
	_base_volume_db = volume_db
	
	next()


func _process(_delta: float):
	if is_paused or state != State.PLAYING:
		return
	
	if time_left <= fade:
		fade_out()


func _on_track_ended():
	track_ended.emit()
	stream = null
	
	var break_duration = randf_range(break_min, break_max)
	
	if break_duration > 0:
		state = State.BREAK
		break_timer.start(break_duration)
	elif auto:
		next()


func _on_break_ended():
	break_ended.emit()
	if auto:
		next()


func _on_fade_finished():
	if state != State.FADING:
		return
	
	stop()
	_reset_fade()
	_on_track_ended()


func _reset_fade():
	if _fade_out_tween and _fade_out_tween.is_valid():
		_fade_out_tween.stop()
		_fade_out_tween = null
	state = State.IDLE
	volume_db = _base_volume_db


func _log_to_history(index: int):
	if not history.is_empty() and index == history[-1]:
		return
	
	history.push_back(index)
	if len(history) >= history_limit:
		history.pop_front()


func _refill_shuffle_pool():
	if playlist.is_empty():
		shuffle_pool = []
		return
	if len(playlist) == 1:
		shuffle_pool = [0]
		return
	
	shuffle_pool.clear()
	for i in range(playlist.size()):
		if i != playlist_index:
			shuffle_pool.append(i)
	shuffle_pool.shuffle()


func _get_next_track_index() -> int:
	var index = 0
	
	if playlist.is_empty():
		return index
	
	match order:
		Order.SEQUENTIAL:
			index = (playlist_index + 1) % playlist.size()
		Order.SHUFFLE:
			if shuffle_pool.is_empty():
				_refill_shuffle_pool()
			index = shuffle_pool[len(shuffle_pool) - 1]
			shuffle_pool.pop_back()
	
	return index


func _get_last_track_index() -> int:
	if history.is_empty():
		return 0
	return history[-1]


## Adds a new track to the end of the [member playlist].
func add_track(track: AudioStream):
	playlist.push_back(track)
	_refill_shuffle_pool()


## Play a track from the [member playlist] under given [param index].
## [br][br]NOTE: [method posmod] is used to always keep the [param index] in bounds.
func play_track(index: int, record_history: bool = true):
	if playlist.is_empty():
		return
	
	is_paused = false
	_reset_fade()
	break_timer.stop()
	
	if record_history and playlist_index >= 0:
		_log_to_history(playlist_index)
	playlist_index = posmod(index, playlist.size())
	
	stream = playlist[playlist_index]
	play()
	
	state = State.PLAYING
	track_started.emit()


## Plays the next track (see [member order]).
func next():
	play_track(_get_next_track_index())


## Plays the last track (or restarts the current one if there's nothing to go
## back to in [member history]).
func back():
	if history.is_empty():
		seek(0)
		return
	
	var last_track_index = _get_last_track_index()
	history.pop_back()
	play_track(last_track_index, false)


## Pauses the player (or set [member is_paused] directly).
func pause():
	is_paused = true


## Unpauses the player (or set [member is_paused] directly).
func unpause():
	is_paused = false


## Starts to fade out the current track's volume if one is playing.[br]
## Then follows a time break of [member break_min] to [member break_max] seconds
## (set with [member delay]).[br]After that will attempt to start the next
## track if the [member auto] [code]true[/code].
func fade_out():
	match state:
		State.FADING:
			return
		State.BREAK, State.IDLE:
			return _on_track_ended()
	state = State.FADING
	
	_base_volume_db = volume_db
	_fade_out_tween = create_tween()
	_fade_out_tween.tween_method(
		func(value):
			volume_db = linear_to_db(value),
		db_to_linear(volume_db),
		0.0,
		fade
		)
	_fade_out_tween.finished.connect(_on_fade_finished)
