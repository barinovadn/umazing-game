@tool
@icon("teleport.png")

class_name TeleportCatExit
extends Teleport

signal fight_ended

@export var ninja_green : Character2D
@export var animated_sprite_2d: AnimatedSprite2D 
@export var enemy_controller: EnemyMovementController2D
@export var pig_follow: BehaviourFollow2D
@export var ninja_blue_follow: BehaviourFollow2D
@export var player_controller: PlayerMovementController2D 
@export var player_ui : UI
@export var teleport_intro : Teleport

func _process(_delta: float):
	if !visible:
		return
	queue_redraw()

func _on_body_entered(body: Node2D):
	if not exit:
		return
	
	var character := body as Character2D
	
	if not character:
		return
	fight_ended.emit()
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
