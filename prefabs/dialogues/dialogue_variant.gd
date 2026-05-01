class_name DialogueVariant
extends Resource


enum DisplayMode { INHERIT, BUBBLE, WINDOW }

@export var id: StringName = &"default"
@export var lines: Array[String] = []
@export var speaker_name: String = ""
@export var portrait_texture: Texture2D
@export var dialogue_preset: String = ""
@export var display_mode: DisplayMode = DisplayMode.INHERIT


func pick_text(fallback: Array[String]) -> String:
	if not lines.is_empty():
		return lines.pick_random()
	if not fallback.is_empty():
		return fallback.pick_random()
	return ""
