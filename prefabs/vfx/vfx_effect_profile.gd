class_name VFXProfile
extends Resource


@export var effect := VFXManager2D.Effect.BREAK_ROCKS
@export var settings: VFXEffectSettings


func spawn(at: Vector2):
	Game.vfx_manager.spawn(effect, at, settings)
