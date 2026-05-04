@icon("vfx_manager.png")
class_name VFXManager2D
extends Node2D


## Value pattern is as follows: [code]VFXEffectName = [Type]_[Variation][/code].
## [br]1_0-999_9 - Dynamic effects; 999_9+ - Static effects.
enum Effect {
	# Dynamic
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
	# Static
	FIREFLIES = 1000_0,
	}

@export var effects: Dictionary[Effect, PackedScene]


func spawn(effect: Effect, at: Vector2) -> VFXEffect2D:
	if not effects.has(effect):
		push_warning("Effect with key \""+str(effect)+"\" not found.")
		return null
	
	var instance := effects[effect].instantiate() as VFXEffect2D
	if not instance:
		push_error("Could not instantiate an effect with key \""+str(effect)+"\".")
		return null
	
	instance.position = at
	add_child(instance)
	return instance
