@tool
@icon("breakable.png")
class_name Breakable2D
extends StaticBody2D


signal spawned()
signal hit()
signal broken()

enum State { LOADING, SPAWNING, IDLE, BROKEN, RESPAWNING, DELETING }

@export var settings: Breakable:
	set(value):
		settings = value
		if is_inside_tree():
			_apply_settings()

@onready var _sprite: Sprite2D = $Sprite
@onready var _collider: CollisionShape2D = $Collider
@onready var _hurt_component: HurtComponent = $HurtComponent
@onready var _sound_player: AudioStreamPlayer2D = $SoundPlayer
@onready var _respawn_timer: Timer = $RespawnTimer

var _respawn_count: int = 0
var state: State:
	set(value):
		if value == state or state == State.DELETING:
			return
		
		state = value
		
		if not Engine.is_editor_hint():
			_on_state_changed()


func _ready():
	_apply_settings()
	spawn()


func _on_respawn_timer_timeout():
	spawn()


func _on_hurt_component_fatal_damage_taken():
	destroy()


func _on_hurt_component_damaged(_by_amount: float):
	hit.emit()
	if settings and settings.vfx_hit:
		settings.vfx_hit.spawn(global_position)


func _on_state_changed():
	match state:
		State.SPAWNING:
			if settings and settings.vfx_spawn:
				settings.vfx_spawn.spawn(global_position)
			set_deferred("state", State.IDLE)
		State.IDLE:
			visible = true
			_collider.set_deferred("disabled", false if _collider.shape else true)
			_hurt_component.current_health = _hurt_component.max_health
			spawned.emit()
			if len(settings.sounds_spawn) > 0:
				_sound_player.stream = settings.sounds_spawn.pick_random()
				_sound_player.play()
		State.BROKEN:
			visible = false
			_collider.set_deferred("disabled", true)
			broken.emit()
			if not settings:
				return delete()
			if settings.vfx_break:
				settings.vfx_break.spawn(global_position)
			if settings.respawn_enabled:
				if( settings.delete_once_broken
					and settings.respawn_lifes > 0
					and _respawn_count >= settings.respawn_lifes ):
					return delete()
				if settings.respawn_duration > 0:
					_respawn_timer.start(settings.respawn_duration)
					state = State.RESPAWNING
				else:
					spawn()
				_respawn_count += 1
			else:
				delete()
		State.DELETING:
			if settings and settings.afterlife_duration > 0:
				await get_tree().create_timer(settings.afterlife_duration).timeout
			queue_free()


func _apply_settings():
	_sprite.texture = settings.texture
	_collider.shape = settings.shape
	if settings.shape: _hurt_component.shape = settings.shape
	_hurt_component.max_health = settings.hp
	_hurt_component.sounds_damage = settings.sounds_hit
	_hurt_component.sounds_die = settings.sounds_break


func spawn():
	state = State.SPAWNING


func destroy():
	state = State.BROKEN


func delete():
	state = State.DELETING
