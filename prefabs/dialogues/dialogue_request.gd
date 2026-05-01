class_name DialogueRequest
extends Resource

enum DisplayMode {
	BUBBLE,
	WINDOW
}
enum CloseMode {
	AUTO_TIMER,
	BY_ACTION,
	MANUAL
}

@export var display_mode: DisplayMode = DisplayMode.BUBBLE
@export_multiline var text: String = ""
@export var lines: Array[String] = []
@export var portrait: Texture2D
@export var speaker_name: String = ""
@export var duration: float = -1.0
@export var preset: String = "npc"

@export_group("Text Size Overrides")
@export var name_font_size: int = -1
@export var text_font_size: int = -1

@export_group("Flow")
@export var close_mode: CloseMode = CloseMode.AUTO_TIMER
@export var allow_skip: bool = true
@export var block_movement: bool = false
@export var wait_until_closed: bool = true


func get_text() -> String:
	var value := text.strip_edges()
	if not value.is_empty():
		return value

	if lines.is_empty():
		return ""

	return lines.pick_random()

func get_duration_estimate(base_duration: float = 2.4, seconds_per_char: float = 0.04) -> float:
	if duration > 0.0:
		return duration

	return max(base_duration, float(get_text().length()) * seconds_per_char)
