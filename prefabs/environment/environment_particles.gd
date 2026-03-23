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
	}

enum Ratio {
	SMALL = 25,
	MEDIUM = 50,
	LARGE = 100,
	}

## Maps particle [enum Types] to their corresponding [GPUParticles2D] nodes.
@onready var particles: Dictionary[Type, GPUParticles2D] = {
	Type.LEAVES: $Leaves,
	Type.LEAVES_PINK: $LeavesPink,
	Type.RAIN: $Rain,
	Type.SNOW: $Snow,
	}


## Sets the emission state for a specific particle [param type] or group
## ([member Type.ALL], [member Type.NONE]). [member GPUParticles2D.amount_ratio]
## is set to equal [param ratio] divided by [code]100[/code].
## Returns [code]false[/code] when receiving an incorrect [param type].
## [br][br][b]Note:[/b] [member Type.NONE] acts as an opposite to [member Type.ALL].
func set_particles(type: Type, emitting: bool, ratio: float = Ratio.LARGE) -> bool:
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
	
	particles[type].emitting = emitting
	particles[type].amount_ratio = ratio/100.0
	return true


## Enables a specific particle type using [method set_particles].
func enable(type: Type, ratio: float = Ratio.LARGE):
	set_particles(type, true, ratio)


## Disables a specific particle type using [method set_particles].
## Does nothing if [member Type.NONE] is passed.
func disable(type: Type):
	if type == Type.NONE:
		return
	set_particles(type, false)


## Enables all particle systems. See [method set_particles] for [param ratio] info. 
func enable_all(ratio: float = Ratio.LARGE):
	for particles_node: GPUParticles2D in particles.values():
		particles_node.emitting = true
		particles_node.amount_ratio = ratio/100.0


## Disables all particle systems.
func disable_all():
	for particles_node: GPUParticles2D in particles.values():
		particles_node.emitting = false
