@icon("environment_zone.png")
class_name EnvironmentZone
extends Area2D
## A region that triggers [EnvironmentParticles] changes when the [Player]
## enters or exits.


@export_group("Entering", "enter")

@export_subgroup("Particles", "enter_particles")
## If [code]true[/code], disables all environment particles when entering
## this zone, except for those selected in [member enter_particles_enable].
@export var enter_particles_strict: bool = false
## List of environment particle types to enable when the player enters this zone.
@export var enter_particles_enable: Array[EnvironmentParticles.Type] = [
	EnvironmentParticles.Type.NONE,
	]
## Amount ratio for corresponding particles from [member enter_particles_enable].
## If not specified defaults to [member EnvironmentParticles.Ratio.SMALL].
@export var enter_particles_ratio: Array[EnvironmentParticles.Ratio]

@export_subgroup("Filter", "enter_filter")
## Whether or not to apply [member enter_filter_color].
@export var enter_filter_apply: bool = true
## The [member EnvironmentFilter.color] to be applied when entering this zone.
@export var enter_filter_color: Color = Color(0, 0, 0, 0)

@export_subgroup("Music", "music")
## Whether or not to apply [MusicPlayer] settings.
@export var music_apply: bool = true
## See [member MusicPlayer.playlist].
@export var music_playlist: Array[AudioStream]
## See [member MusicPlayer.auto].
@export var music_auto: bool = true
## See [member MusicPlayer.order].
@export var music_order: MusicPlayer.Order = MusicPlayer.Order.SEQUENTIAL
## See [member MusicPlayer.delay].
@export var music_delay: MusicPlayer.Delay = MusicPlayer.Delay.NORMAL
## See [member MusicPlayer.fade].
@export var music_fade: float = 3.0

@export_group("Exiting", "exit")

@export_subgroup("Particles", "exit_particles")
## If [code]true[/code], disables all environment particles from
## [member enter_particles_enable] when the player exits this zone.
@export var exit_particles_clear: bool = true
## List of environment particle types to explicitly disable when exiting this zone.
@export var exit_particles_disable: Array[EnvironmentParticles.Type]

@export_subgroup("Filter", "exit_filter")
## Whether or not to apply [member exit_filter_color].
@export var exit_filter_apply: bool = false
## The [member EnvironmentFilter.color] to be applied when exiting this zone.
@export var exit_filter_color: Color = Color(0, 0, 0, 0)

@onready var environment_particles: EnvironmentParticles = %Player/%EnvironmentParticles
@onready var environment_filter: EnvironmentFilter = %Player/%EnvironmentFilter
@onready var music_player: MusicPlayer = %MusicPlayer

var exit_frame: float = 0
var enter_frame: float = 0


func _on_area_entered(_area: Area2D):
	enter_frame = Engine.get_process_frames()
	
	if exit_frame == enter_frame:
		return
	
	get_tree().process_frame.connect(apply_on_enter_effects, CONNECT_ONE_SHOT)


func _on_area_exited(_area: Area2D):
	exit_frame = Engine.get_process_frames()
	
	call_deferred('_on_area_exited_defer')


func _on_area_exited_defer():
	if exit_frame == enter_frame:
		return
	
	apply_on_exit_effects()


func apply_on_enter_effects():
	# Particles
	
	if enter_particles_strict:
		environment_particles.disable_all()
	
	for i in range(len(enter_particles_enable)):
		var type = enter_particles_enable[i]
		var ratio = ( enter_particles_ratio[i] if i < len(enter_particles_ratio)
			else EnvironmentParticles.Ratio.SMALL )
		environment_particles.enable(type, ratio)
	
	# Filter
	
	if enter_filter_apply:
		environment_filter.color = enter_filter_color
	
	# Music
	
	if music_apply:
		music_player.playlist = music_playlist
		music_player.auto = music_auto
		music_player.order = music_order
		music_player.delay = music_delay
		music_player.fade = music_fade
		music_player.fade_out()


func apply_on_exit_effects():
	# Particles
	
	if exit_particles_clear:
		for type in enter_particles_enable:
			environment_particles.disable(type)
	
	for type in exit_particles_disable:
		environment_particles.disable(type)
	
	# Filter
	
	if exit_filter_apply:
		environment_filter.color = exit_filter_color
