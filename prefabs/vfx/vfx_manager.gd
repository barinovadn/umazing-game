@icon("vfx_manager.png")
class_name VFXManager2D
extends Node2D


## Value pattern is as follows: [code]VFX_EFFECT_NAME = [Type]_[Variation][/code].
## [br]Example: [code]BURST_LEAVES_PINK = 11_1[/code].
## [br][br][b]NOTE[/b]: This enum contains both dynamic & static effects.
## Static being those that linger forever or until manually removed
## with [method VFXEffect2D.finish] or [method VFXEffect2D.delete],
## like [member Effect.FIREFLIES] or [member Effect.SMOKE].
## Make sure you preview & know what particle you're spawning in beforehand.
enum Effect {
	BREAK_ROCKS = 1_0,
	BREAK_ROCKS_GRAY = 1_1,
	BREAK_VASE = 2_0,
	BREAK_WOOD = 3_0,
	BREAK_BAMBOO = 4_0,
	
	BURST_GRASS = 10_0,
	BURST_LEAVES = 11_0,
	BURST_LEAVES_PINK = 11_1,
	
	PUFF_SPARK = 20_0,
	PUFF_SNOW = 21_0,
	
	SMOKE = 30_0,
	SMOKE_EXPLOSION = 31_0,
	
	FIREFLIES = 40_0,
	
	PORTAL = 50_0,
	}

## Maps [VFXEffect2D] IDs from the [enum Effect] to сorresponding effect scenes.
@export var effects: Dictionary[Effect, PackedScene]


func spawn(effect: Effect, at: Vector2,
	settings: VFXEffectSettings = null) -> VFXEffect2D:
	if not effects.has(effect):
		push_warning("Effect with key \""+str(effect)+"\" not found.")
		return null
	
	var instance := effects[effect].instantiate() as VFXEffect2D
	if not instance:
		push_error("Could not instantiate an effect with key \""+str(effect)+"\".")
		return null
	
	instance.position = at
	instance.settings = settings
	add_child(instance)
	
	return instance
