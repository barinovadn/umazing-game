class_name Breakable
extends Resource


@export var texture: Texture2D
@export var shape: Shape2D
@export var hp: float = 1.0
@export var team: HurtComponent.Team = HurtComponent.Team.BREAKABLE
@export var delete_once_broken: bool = true

@export_group("Respawn", "respawn")
@export var respawn_enabled: bool = false
@export var respawn_lifes: int = 0
@export var respawn_duration: float = 1.0

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
