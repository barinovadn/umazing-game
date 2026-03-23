@icon("environment_zone.png")
class_name EnvironmentZone
extends Area2D
## A region that triggers [EnvironmentParticles] changes when the [Player]
## enters or exits.


@export_group("Entering", "enter")
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

@export_group("Exiting", "exit")
## If [code]true[/code], disables all environment particles from
## [member enter_particles_enable] when the player exits this zone.
@export var exit_particles_clear: bool = true
## List of environment particle types to explicitly disable when exiting this zone.
@export var exit_particles_disable: Array[EnvironmentParticles.Type]

@onready var environment_particles: EnvironmentParticles = %Player/%EnvironmentParticles


func _on_area_entered(_area: Area2D):
	if enter_particles_strict:
		environment_particles.disable_all()
	
	for i in range(len(enter_particles_enable)):
		var type = enter_particles_enable[i]
		var ratio = ( enter_particles_ratio[i] if i < len(enter_particles_ratio)
			else EnvironmentParticles.Ratio.SMALL )
		environment_particles.enable(type, ratio)


func _on_area_exited(_area: Area2D):
	if exit_particles_clear:
		for type in enter_particles_enable:
			environment_particles.disable(type)
	
	for type in exit_particles_disable:
		environment_particles.disable(type)
