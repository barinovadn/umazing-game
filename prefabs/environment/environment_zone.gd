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
@export var enter_filter_apply: bool = false
## The [member EnvironmentFilter.color] to be applied when entering this zone.
@export var enter_filter_color: Color = Color(0, 0, 0, 0)

@export_group("Exiting", "exit")

# WARNING There's still an unfixed bug remaining with the exit effects:
# If two zones (A&B) are located next to each other,
# Once the player goes from zone A to B - they will trigger the B's enter effects,
# And only after that will the A's exit effects start to apply.
# FIXME (Which should idealy be the other way around...).

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


func _on_area_entered(_area: Area2D):
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


func _on_area_exited(_area: Area2D):
	# Particles
	
	if exit_particles_clear:
		for type in enter_particles_enable:
			environment_particles.disable(type)
	
	for type in exit_particles_disable:
		environment_particles.disable(type)
	
	# Filter
	
	if exit_filter_apply:
		environment_filter.color = exit_filter_color
