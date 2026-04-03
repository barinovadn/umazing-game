@tool
@icon("teleport.png")
class_name TeleportBossOut
extends Area2D

signal player_entered

@export var exit: Node2D
@export var exit_offset: Vector2
@export var color: Color


func _process(_delta: float):
	if !visible:
		return
	queue_redraw()


func _on_body_entered(body: Node2D):
	if not exit:
		return
	
	player_entered.emit()
	
	var character := body as Character2D
	
	if not character:
		return
	
	character.global_position = exit.global_position + exit_offset
	
func _draw() -> void:
	if not Engine.is_editor_hint() or not exit or not color:
		return
	
	var start = Vector2.ZERO
	var mid = to_local(exit.global_position)
	var end = to_local(exit.global_position + exit_offset)
	
	draw_circle(end, 5, color)
	draw_dashed_line(start, mid, color, 2.5)
	draw_dashed_line(mid, end, color, 2.5)
	draw_circle(end, 5, color)
