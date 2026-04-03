@icon("inspectable.png")
class_name Inspectable
extends Interactable
## Displays a random [member description] when interacted with.


enum DialogueDisplayMode { BUBBLE, WINDOW }

## List of possible description texts.
## A random entry is chosen when the object is inspected using [method interact].
@export var description: Array[String] = ["..."]

@export_group("Dialogue")
@export var dialogue_display_mode: DialogueDisplayMode = DialogueDisplayMode.BUBBLE
@export var speaker_name: String = ""
@export var portrait_texture: Texture2D
@export var dialogue_preset: String = "npc"

@export_group("Dialogue Variants")
@export var dialogue_variants: Array[DialogueVariant] = []
@export var current_dialogue_variant: StringName = &""
@export var cycle_dialogue_variants_on_interact: bool = false

var _dialogue_variant_index: int = 0


func _on_interaction():
	var variant := _resolve_dialogue_variant()
	var text := _resolve_text(variant)
	if text.is_empty():
		return false

	var ds = get_tree().get_first_node_in_group("dialogue_system")
	if ds == null:
		var nodes := get_tree().get_nodes_in_group("dialogue_system")
		if nodes.size() > 0:
			ds = nodes[0]

	if ds == null:
		print('"', text, '"')
		_advance_dialogue_variant_if_needed(variant)
		return true

	match _resolve_display_mode(variant):
		DialogueDisplayMode.WINDOW:
			if ds.has_method("show_dialogue_window"):
				ds.show_dialogue_window(
					text,
					_resolve_portrait_texture(variant),
					_resolve_speaker_name(variant),
					-1.0,
					_resolve_preset(variant)
				)
			elif ds.has_method("say"):
				ds.say(self, text)
		_:
			if ds.has_method("say"):
				ds.say(self, text, -1.0, _resolve_preset(variant))
			else:
				print('"', text, '"')

	_advance_dialogue_variant_if_needed(variant)
	return true


func set_dialogue_variant(variant_id: StringName) -> void:
	current_dialogue_variant = variant_id
	
	for i in dialogue_variants.size():
		var candidate_variant := dialogue_variants[i]
		if candidate_variant != null and candidate_variant.id == variant_id:
			_dialogue_variant_index = i
			return


func next_dialogue_variant() -> void:
	if dialogue_variants.is_empty():
		return

	_dialogue_variant_index = wrapi(_dialogue_variant_index + 1, 0, dialogue_variants.size())
	var variant := dialogue_variants[_dialogue_variant_index]
	if variant != null:
		current_dialogue_variant = variant.id


func _resolve_text(variant: DialogueVariant) -> String:
	if variant != null:
		return variant.pick_text(description)
	if description.is_empty():
		return ""
	return description.pick_random()


func _resolve_dialogue_variant() -> DialogueVariant:
	if dialogue_variants.is_empty():
		return null

	if not String(current_dialogue_variant).is_empty():
		for i in dialogue_variants.size():
			var candidate_variant := dialogue_variants[i]
			if candidate_variant != null and candidate_variant.id == current_dialogue_variant:
				_dialogue_variant_index = i
				return candidate_variant

	_dialogue_variant_index = clampi(_dialogue_variant_index, 0, dialogue_variants.size() - 1)
	var active_variant := dialogue_variants[_dialogue_variant_index]
	if active_variant != null:
		current_dialogue_variant = active_variant.id
	return active_variant



func _advance_dialogue_variant_if_needed(current_variant: DialogueVariant) -> void:
	if not cycle_dialogue_variants_on_interact:
		return
	if dialogue_variants.size() < 2:
		return

	if current_variant == null:
		next_dialogue_variant()
		return

	var current_index := dialogue_variants.find(current_variant)
	if current_index == -1:
		next_dialogue_variant()
		return

	_dialogue_variant_index = wrapi(current_index + 1, 0, dialogue_variants.size())
	var next_variant := dialogue_variants[_dialogue_variant_index]
	if next_variant != null:
		current_dialogue_variant = next_variant.id


func _resolve_display_mode(variant: DialogueVariant) -> DialogueDisplayMode:
	if variant != null:
		match variant.display_mode:
			DialogueVariant.DisplayMode.BUBBLE:
				return DialogueDisplayMode.BUBBLE
			DialogueVariant.DisplayMode.WINDOW:
				return DialogueDisplayMode.WINDOW
	return dialogue_display_mode


func _resolve_preset(variant: DialogueVariant) -> String:
	if variant != null:
		var value := variant.dialogue_preset.strip_edges()
		if not value.is_empty():
			return value
	return dialogue_preset


func _resolve_speaker_name(variant: DialogueVariant = null) -> String:
	if variant != null:
		var variant_name := variant.speaker_name.strip_edges()
		if not variant_name.is_empty():
			return variant_name

	var value := speaker_name.strip_edges()
	if not value.is_empty():
		return value

	var parent := get_parent()
	if parent != null and parent.get("dialogue_name") != null:
		value = String(parent.get("dialogue_name")).strip_edges()

	return value


func _resolve_portrait_texture(variant: DialogueVariant = null) -> Texture2D:
	if variant != null and variant.portrait_texture != null:
		return variant.portrait_texture

	if portrait_texture != null:
		return portrait_texture

	var parent := get_parent()
	if parent != null:
		var value = parent.get("portrait_texture")
		if value is Texture2D:
			return value

	return null
