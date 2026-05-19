class_name VFXEffectSettings
extends Resource


enum Density { NONE, LOW, MEDIUM, HIGH, FULL }

@export var modulate: Color = Color.WHITE
@export var offset: Vector2 = Vector2.ZERO
@export var scale: Vector2 = Vector2.ONE
@export var density: Density = Density.MEDIUM

const DENSITY_VALUES = {
	Density.NONE: 0.0,
	Density.LOW: 0.25,
	Density.MEDIUM: 0.5,
	Density.HIGH: 0.75,
	Density.FULL: 1.0
	}
