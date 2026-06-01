@icon("dialogue_system.png")
class_name DialogueSystem
extends CanvasLayer

signal dialogue_started()
signal dialogue_closed()

enum State { LOADING, HIDDEN, APPEARING, ACTIVE, HIDING }

@export var skip_cooldown: float = 1.0
@export var auto_skip: bool = false:
	set(value):
		auto_skip = value
		if auto_skip_button:
			auto_skip_button.modulate = Color.LIME if auto_skip else Color.WHITE
		if auto_skip_timer:
			if auto_skip:
				auto_skip_timer.start(auto_skip_delay)
			else:
				auto_skip_timer.stop()
@export var auto_skip_delay: float = 1.0

@export_group("Typing")
@export var char_type_speed_multipliers: Dictionary[String, float]

@export_group("Animations")
@export var window_appear_duration: float = .3
@export var window_hide_duration: float = .2

@onready var dialogue_window: Control = %DialogueWindow
@onready var dialogue_canvas: CanvasGroup = %CanvasGroup

@onready var dialogue_icon: TextureRect = %Icon
@onready var dialogue_name: Label = %Name
@onready var dialogue_message: Label = %Message
@onready var dialogue_background: ColorRect = %Background

@onready var typing_timer: Timer = $Typing
@onready var skip_timer: Timer = $Skip
@onready var auto_skip_timer: Timer = $AutoSkip
@onready var auto_skip_button: Button = $DialogueWindow/CanvasGroup/AutoSkip

var state: State:
	set(value):
		if value == state:
			return
		state = value
		_update_animation()
var dialogue: Dialogue:
	set(value):
		if value == dialogue:
			return
		
		dialogue = value
		
		if not dialogue:
			match state:
				State.ACTIVE: state = State.HIDING
			return
	
		match state:
			State.HIDDEN: state = State.APPEARING
		
		dialogue_icon.texture = dialogue.icon
		dialogue_name.text = dialogue.name
		dialogue_name.label_settings.font_color = dialogue.font_color
		dialogue_message.label_settings.font_color = dialogue.font_color
		dialogue_background.color = dialogue.background
		dialogue_window.rotation = deg_to_rad(dialogue.angle)
		
		_update_animation()
		_on_dialogue_started()
		_start_typing_animation()
var dialogue_queue: Array[Dialogue]: # NOTE Only setting, no appending
	set(value):
		dialogue_queue = value
		if dialogue_queue.size() > 0:
			dialogue_started.emit()
			_on_dialogue_started()
			if not dialogue:
				next()
var _active_tween: Tween # NOTE Using tweens for dynamic UI
var _typing_index: int
var is_fully_typed: bool:
	get():
		if not dialogue:
			return false
		return (
			dialogue_message.text == dialogue.message
			or _typing_index >= len(dialogue.message) )
var is_on_skip_cooldown: bool:
	get():
		return not skip_timer.is_stopped()


func _ready():
	state = State.HIDDEN
	auto_skip = auto_skip


func _input(event: InputEvent):
	if event.is_action_pressed("dialogue_skip"):
		skip()


func _on_dialogue_started():
	if not Game.player or not Game.player.character:
		return
	
	Game.player.stat_cant_use_inventory.add_modifier("ACTIVE_DIALOGUE")
	Game.player.character.stat_cant_move.add_modifier("ACTIVE_DIALOGUE")
	Game.player.character.stat_cant_shoot.add_modifier("ACTIVE_DIALOGUE")
	Game.player.character.stat_cant_interract.add_modifier("ACTIVE_DIALOGUE")


func _on_dialogue_closed():
	if not Game.player or not Game.player.character:
		return
	
	Game.player.stat_cant_use_inventory.remove_modifier("ACTIVE_DIALOGUE")
	Game.player.character.stat_cant_move.remove_modifier("ACTIVE_DIALOGUE")
	Game.player.character.stat_cant_shoot.remove_modifier("ACTIVE_DIALOGUE")
	Game.player.character.stat_cant_interract.remove_modifier("ACTIVE_DIALOGUE")
	
	Game.player.character.interactor.set_on_cooldown()


func _on_character_typed():
	type_next_character()


func _on_skip_pressed():
	skip()


func _on_auto_skip_toggled(toggled_on: bool):
	auto_skip = toggled_on


func _on_auto_skip_timeout():
	skip(true, false)


func _get_character_type_speed(character: String) -> float:
	var is_special_char := character in char_type_speed_multipliers
	var char_type_speed_multiplier := (
		char_type_speed_multipliers[character] if is_special_char else 1.0 )
	
	if not dialogue:
		return char_type_speed_multiplier
	
	if is_special_char:
		char_type_speed_multiplier *= dialogue.punctuation_significance
	
	return dialogue.TYPE_SPEEDS[dialogue.type_speed] * char_type_speed_multiplier


func _update_animation():
	if _active_tween:
		_active_tween.kill()
	
	# NOTE If you wanna use opacity in tween animations
	#      Then use dialogue_canvas's self_modulate:a property
	match state:
		State.HIDDEN:
			dialogue_window.visible = false
			dialogue_canvas.position = Vector2(0, 200.0)
			dialogue_window.scale = Vector2(0.75, 0.75)
			#dialogue = null
		
		State.APPEARING:
			dialogue_window.visible = true
			dialogue_window.pivot_offset = dialogue_window.size / 2
			
			_active_tween = create_tween().set_parallel(true)
			_active_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			
			_active_tween.tween_property(dialogue_canvas,
				"position", dialogue.offset if dialogue else Vector2.ZERO,
				window_appear_duration)
			_active_tween.tween_property(dialogue_window,
				"scale", Vector2.ONE, window_appear_duration)
			
			_active_tween.finished.connect(_on_appearing_tween_finished)
		
		State.ACTIVE:
			dialogue_window.visible = true
			dialogue_canvas.position = dialogue.offset if dialogue else Vector2.ZERO
			dialogue_window.scale = Vector2.ONE
		
		State.HIDING:
			_active_tween = create_tween().set_parallel(true)
			_active_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			
			_active_tween.tween_property(dialogue_canvas,
				"position:y", 200.0, window_hide_duration)
			_active_tween.tween_property(dialogue_window,
				"scale", Vector2(0.75, 0.75), window_hide_duration)
			
			_active_tween.finished.connect(_on_hiding_tween_finished)


func _on_appearing_tween_finished():
	if state == State.APPEARING:
		state = State.ACTIVE


func _on_hiding_tween_finished():
	if state == State.HIDING:
		state = State.HIDDEN


func _start_typing_animation():
	if not dialogue:
		return
	match dialogue.type_speed:
		dialogue.TypeSpeed.INSTANT:
			show_whole_message()
			return
	
	_typing_index = 0
	dialogue_message.text = ""
	type_next_character()


func show_whole_message():
	if not dialogue:
		return
	dialogue_message.text = dialogue.message
	_typing_index = len(dialogue.message)


func type_next_character():
	if not dialogue or is_fully_typed:
		return
	
	var new_char := dialogue.message[_typing_index]
	var new_speed := _get_character_type_speed(new_char)
	
	if new_speed <= 0:
		show_whole_message()
		return
	
	dialogue_message.text += new_char
	_typing_index += 1
	typing_timer.start(new_speed)


func queue_dialogues(new_dialogue_queue: Array[Dialogue]):
	dialogue_queue = new_dialogue_queue


func display(new_dialogue: Dialogue, clear_queue: bool = true):
	if clear_queue:
		dialogue_queue = []
	dialogue = new_dialogue


func skip(ignore_cooldown: bool = false, close_on_finish: bool = true):
	if not dialogue:
		close()
		return
	if is_on_skip_cooldown and not ignore_cooldown:
		return
	if not is_fully_typed:
		show_whole_message()
	elif len(dialogue_queue) > 0:
		next()
	elif close_on_finish:
		close()
	if not ignore_cooldown:
		skip_timer.start(skip_cooldown)


func next():
	for i in len(dialogue_queue):
		if dialogue_queue[i]:
			display(dialogue_queue[i], false)
			dialogue_queue = dialogue_queue.slice(i+1, len(dialogue_queue))
			break


func close():
	dialogue_queue.clear()
	dialogue = null
	is_fully_typed = false
	_typing_index = 0
	# I'll be honest, I ain't sure if we should uncomment this
	# await get_tree().process_frame
	_on_dialogue_closed()
	dialogue_closed.emit()
