@icon("vfx_effect.png")
class_name VFXEffect2D
extends Node2D


signal gpu_particles_finished
signal all_gpu_particles_finished
signal paused
signal unpaused
signal finished
signal deleted

enum OffScreenBehaviour {
	NONE,
	PAUSE,
	DELETE,
	FINISH,
	}

@export var gpu_particles: Array[GPUParticles2D]
@export var off_screen_behaviour: OffScreenBehaviour
@export var pause_delay: float = 0.0
@export var delete_once_finished: bool

var _gpu_particles_awaiting_count: int = 0
var _gpu_particles_finished_count: int = 0:
	set(value):
		var has_increased := value > _gpu_particles_finished_count
		_gpu_particles_finished_count = value
		if has_increased:
			gpu_particles_finished.emit()
			if _all_gpu_particles_finished:
				all_gpu_particles_finished.emit()
				_finished_check()
var _all_gpu_particles_finished: bool:
	get():
		return _gpu_particles_finished_count >= _gpu_particles_awaiting_count

var is_finished: bool = false:
	set(value):
		if is_finished == value or is_finished:
			return
		is_finished = value
		if is_finished:
			finished.emit()
			if delete_once_finished:
				delete()
var is_paused: bool = false:
	set(value):
		if value == is_paused:
			return
		is_paused = value
		if is_paused:
			if pause_delay > 0.001:
				await get_tree().create_timer(pause_delay).timeout
			process_mode = Node.PROCESS_MODE_DISABLED
			paused.emit()
		else:
			process_mode = Node.PROCESS_MODE_INHERIT
			unpaused.emit()


func _ready():
	for particles in gpu_particles:
		if particles.finished.is_connected(_on_gpu_particles_finished):
			continue
		particles.emitting = true
		_gpu_particles_awaiting_count += 1
		particles.finished.connect(_on_gpu_particles_finished)


func _on_screen_exited():
	match off_screen_behaviour:
		OffScreenBehaviour.PAUSE: pause()
		OffScreenBehaviour.DELETE: delete()
		OffScreenBehaviour.FINISH: finish()
		OffScreenBehaviour.NONE, _: pass


func _on_screen_entered():
	match off_screen_behaviour:
		OffScreenBehaviour.PAUSE: unpause()
		OffScreenBehaviour.NONE, _: pass


func _finished_check():
	is_finished = _all_gpu_particles_finished


func _on_gpu_particles_finished():
	_gpu_particles_finished_count += 1


func pause():
	is_paused = true


func unpause():
	is_paused = false


func finish():
	if is_finished:
		return
	
	if not _all_gpu_particles_finished:
		print('FINISH FASTER GODDAMIT')
		for particles in gpu_particles:
			# BUG Issue whith Godot's (4.6.2.stable) GPUParticles2D.one_shot:
			#     Changing it's value to "true" at runtime will not trigger
			#     GPUParticles2D.finished signal at the end of the cycle
			# See https://github.com/godotengine/godot/issues/93991
			particles.one_shot = true
			# BUG Workaround
			get_tree().create_timer(particles.lifetime).timeout.connect(
				_on_gpu_particles_finished)


func delete():
	queue_free()
	deleted.emit()
