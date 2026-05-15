@icon("dialogue_system.png")
class_name DialogueSystem
extends CanvasLayer


enum State { LOADING, HIDDEN, APPEARING, ACTIVE, HIDING }

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
			return
		
		dialogue_icon.texture = dialogue.icon
		dialogue_name.text = dialogue.name
		dialogue_background.color = dialogue.background
		dialogue_window.rotation = deg_to_rad(dialogue.angle)
		
		_update_animation()
		_start_typing_animation()
var _active_tween: Tween # NOTE Using tweens for dynamic UI
var _typing_index: int
var _is_fully_typed: bool:
	get():
		if not dialogue:
			return false
		return (
			dialogue_message.text == dialogue.message
			or _typing_index >= len(dialogue.message) )


func _ready():
	state = State.HIDDEN


func _input(event: InputEvent):
	if event.is_action_pressed("dialogue_skip"):
		if not _is_fully_typed:
			show_whole_message()
		else:
			close()


func _on_character_typed():
	type_next_character()


func _get_character_type_speed(character: String) -> float:
	var is_special_char := character in char_type_speed_multipliers
	var char_type_speed_multiplier := (
		char_type_speed_multipliers[character] if is_special_char else 1.0 )
	
	if not dialogue:
		return char_type_speed_multiplier
	
	if is_special_char:
		char_type_speed_multiplier *= dialogue.punctuation_significance
	
	return dialogue.TYPE_SPEED[dialogue.type_speed] * char_type_speed_multiplier


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
			dialogue = null
		
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
			
			_active_tween.finished.connect(func(): 
				match state:
					State.APPEARING: state = State.ACTIVE
			)
		
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
			
			_active_tween.finished.connect(func(): 
				match state:
					State.HIDING: state = State.HIDDEN
			)


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
	if not dialogue or _is_fully_typed:
		return
	
	var new_char := dialogue.message[_typing_index]
	var new_speed := _get_character_type_speed(new_char)
	
	if new_speed <= 0:
		show_whole_message()
		return
	
	dialogue_message.text += new_char
	_typing_index += 1
	typing_timer.start(new_speed)


func display(new_dialogue: Dialogue):
	if not new_dialogue:
		return
	
	match state:
		State.HIDDEN: state = State.APPEARING
	
	dialogue = new_dialogue


func close():
	match state:
		State.ACTIVE: state = State.HIDING
