@icon("vfx_manager.png")
class_name VFXManager2D
extends Node2D
## Manages [VFXEffect2D]'s in the scene.


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


## Adds a new [VFXEffect2D] to the scene (as a child for this [VFXManager2D]).
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


## Calls [method VFXEffect2D.delete] on all [VFXEffect2D]s with
## [member VFXEffect2D.Type.DYNAMIC] in the scene. Returns the amount of calls.
## Uses [param group_name] to search for [VFXEffect2D] nodes using
## [method SceneTree.get_nodes_in_group].
func clear(group_name: String = "vfx_effect") -> int:
	if not is_inside_tree():
		push_warning("Trying to call \"clear\" while not in the tree.")
		return 0
	
	var cleared_count = 0
	
	for node in get_tree().get_nodes_in_group(group_name):
		var vfx_effect := node as VFXEffect2D
		
		if not vfx_effect:
			push_warning("Node in group \""+group_name+"\" is not a VFXEffect2D.")
			continue
		
		if vfx_effect.type != VFXEffect2D.Type.DYNAMIC:
			continue
		
		vfx_effect.delete()
		cleared_count += 1
	
	return cleared_count
