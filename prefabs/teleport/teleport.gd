@tool
@icon("teleport.png")
class_name Teleport
extends Area2D


signal used()

@export var exit: Node2D
@export var exit_level_index: int = -1
@export var exit_offset: Vector2
@export var exit_effect: VFXProfile
@export var use_limit: int = 0
@export var color: Color
@export var enabled: bool = true:
	set(value):
		enabled = value
		set_deferred("monitoring", enabled)
		if delete_on_disable and not enabled:
			delete()
@export var delete_on_disable: bool = true

var use_count: int = 0:
	set(value):
		use_count = value
		if use_limit > 0 and use_count >= 1:
			enabled = false


func _process(_delta: float):
	queue_redraw()


func _on_body_entered(body: Node2D):
	use(body as Character2D)


func _draw() -> void:
	if( not Engine.is_editor_hint() or not exit
		or not (color.r or color.g or color.b)):
		return
	
	var start = Vector2.ZERO
	var mid = to_local(exit.global_position)
	var end = to_local(exit.global_position + exit_offset)
	
	draw_circle(end, 5, color)
	draw_dashed_line(start, mid, color, 2.5)
	draw_dashed_line(mid, end, color, 2.5)
	draw_circle(end, 5, color)


func use(character: Character2D):
	if not exit or not visible or not character:
		return
	
	character.global_position = exit.global_position + exit_offset
	
	use_count += 1
	used.emit()
	
	if character == Game.player.character and exit_level_index >= 0:
		
		SceneManager.current_level_index = exit_level_index
		SaveManager.save_game()
		SaveManager.load_game()
		#SceneManager.go_to_level(exit_level_index)
	
	if exit_effect:
		exit_effect.spawn(character.global_position)


func delete():
	queue_free()
