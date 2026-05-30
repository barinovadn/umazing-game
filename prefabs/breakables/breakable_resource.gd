class_name Breakable
extends Resource


@export var texture: Texture2D
@export var shape: Shape2D
@export var hp: float = 1.0
@export var team: HurtComponent.Team = HurtComponent.Team.BREAKABLE
@export var delete_once_broken: bool = true

@export_group("Loot", "loot")
@export_range(0.0, 1.0) var loot_drop_chance: float = 0.0
@export var loot_table: Array[ItemData] = []
@export var loot_weights: Array[float] = []

@export_group("Respawn", "respawn")
@export var respawn_enabled: bool = false
@export var respawn_lifes: int = 0
@export var respawn_duration_min: float = 1.0
@export var respawn_duration_max: float = 1.0

@export_group("Sounds", "sounds")
@export var sounds_spawn: Array[AudioStream]
@export var sounds_hit: Array[AudioStream]
@export var sounds_break: Array[AudioStream]

@export_group("Effects", "vfx")
@export var vfx_spawn: VFXProfile
@export var vfx_hit: VFXProfile
@export var vfx_break: VFXProfile
@export var vfx_emit_spawn_on_ready: bool = false

@export_group("Afterlife", "afterlife")
@export var afterlife_duration: float = 7.0

var respawn_duration: float:
	get(): return randf_range(respawn_duration_min, respawn_duration_max)


func roll_loot(roll: float = -1) -> ItemData:
	if roll < 0:
		if randf() > loot_drop_chance:
			return null
	
	var item_count: int = mini(loot_table.size(), loot_weights.size())
	if item_count == 0:
		return null
	
	var total_weight: float = 0.0
	for i in range(item_count):
		if loot_table[i] != null:
			total_weight += loot_weights[i]
	
	if total_weight <= 0.0:
		return null
	
	if roll < 0:
		roll = randf_range(0.0, total_weight)
	
	var current_weight: float = 0.0
	for i in range(item_count):
		if loot_table[i] != null:
			current_weight += loot_weights[i]
			if roll <= current_weight:
				return loot_table[i]
	
	return null
