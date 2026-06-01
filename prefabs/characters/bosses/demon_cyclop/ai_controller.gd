extends AIController

@export var vfx: VFXProfile
@export var normal_sound: Array[AudioStream]
@export var creepy_sound: Array[AudioStream]


func _on_action(_action: AIAction):
	if _action.action_name == "bomb_and_regen" or _action.action_name == "fire_and_regen":
		modifier.value = -1
		modifier.duration = _action.duration
		modifier.operation = modifier.Operation.multiply
		Game.player.character.stat_damage_ratio.add_modifier(str(modifier.get_instance_id()), modifier)
		hurt_component.sounds_damage = creepy_sound
		vfx.spawn(global_position)
	else:
		hurt_component.sounds_damage = normal_sound
