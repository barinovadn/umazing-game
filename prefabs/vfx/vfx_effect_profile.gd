class_name VFXProfile
extends Resource


@export var effect := VFXManager2D.Effect.BREAK_ROCKS
@export var settings: VFXEffectSettings


func spawn(at: Vector2) -> VFXEffect2D:
	if not Game.vfx_manager:
		return null
	return Game.vfx_manager.spawn(effect, at, settings)
