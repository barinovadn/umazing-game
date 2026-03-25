@icon("environment_particles.png")
class_name EnvironmentParticles
extends Node2D
## Manages environmental particle effects.


enum Type {
	ALL = -1,
	NONE = 0,
	LEAVES = 100,
	LEAVES_PINK = 101,
	RAIN = 200,
	SNOW = 300,
	SUNRAYS = 400,
	CLOUDS = 500,
	}

enum Ratio {
	SMALL = 25,
	MEDIUM = 50,
	LARGE = 100,
	}

## If [code]true[/code], will mutate particles based on things like amount ratio.
## [br][br][b]Behaviours:[/b][br][br]
## [member Type.CLOUDS] - Thicker clouds on high amount ratio.
@export var enable_particle_mutations: bool = true

## Maps particle [enum Types] to their corresponding [GPUParticles2D] nodes.
@onready var particles: Dictionary[Type, GPUParticles2D] = {
	Type.LEAVES: $Leaves,
	Type.LEAVES_PINK: $LeavesPink,
	Type.RAIN: $Rain,
	Type.SNOW: $Snow,
	Type.SUNRAYS: $Sunrays,
	Type.CLOUDS: $Clouds/Clouds,
	}


## [b]Note:[/b] [param ratio] expects a value in range of [code]0.0[/code] to
## [code]1.0[/code] for [member GPUParticles2D.amount_ratio].
func _update_particles(node: GPUParticles2D, emitting: bool, ratio: float = 1.0):
	node.amount_ratio = ratio
	node.emitting = emitting
	if enable_particle_mutations:
		_apply_mutations(node)


func _apply_mutations(node: GPUParticles2D):
	match node.name:
		'Clouds':
			var alpha_min = .015
			var alpha_max = .2
			var alpha = alpha_min + (node.amount_ratio * (alpha_max - alpha_min))
			$Clouds.self_modulate = Color(0, 0, 0, alpha)


## Sets the emission state for a specific particle [param type] or group
## ([member Type.ALL], [member Type.NONE]). [member GPUParticles2D.amount_ratio]
## is set to equal [param amount] divided by [code]100[/code].
## Returns [code]false[/code] when receiving an incorrect [param type].
## [br][br][b]Note:[/b] [member Type.NONE] acts as an opposite to [member Type.ALL].
func set_particles(type: Type, emitting: bool, amount: float = Ratio.LARGE) -> bool:
	match type:
		Type.NONE:
			if emitting: disable_all()
			else: enable_all()
			return true
		Type.ALL:
			if emitting: enable_all()
			else: disable_all()
			return true
	
	if not type in particles.keys():
		return false
	
	_update_particles(particles[type], emitting, amount/100.0)
	return true


## Enables a specific particle type using [method set_particles].
func enable(type: Type, amount: float = Ratio.LARGE):
	set_particles(type, true, amount)


## Disables a specific particle type using [method set_particles].
## Does nothing if [member Type.NONE] is passed.
func disable(type: Type):
	if type == Type.NONE:
		return
	set_particles(type, false)


## Enables all particle systems. See [method set_particles]. 
func enable_all(amount: float = Ratio.LARGE):
	for particles_node: GPUParticles2D in particles.values():
		_update_particles(particles_node, true, amount/100.0)


## Disables all particle systems.
func disable_all():
	for particles_node: GPUParticles2D in particles.values():
		_update_particles(particles_node, false)
