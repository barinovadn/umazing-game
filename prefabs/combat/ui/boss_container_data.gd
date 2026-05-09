class_name BossContainerData
extends Resource


@export var display_name: String = ""
@export var display_color: Color = Color.from_rgba8(18, 18, 18)

@export_group("Textures", "texture")
@export var texture_under: Texture2D
@export var texture_progress: Texture2D
@export var texture_over: Texture2D
