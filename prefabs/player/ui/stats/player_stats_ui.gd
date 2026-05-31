class_name StatsUI
extends Control


@export var show_full: bool = false:
	set(value):
		show_full = value
		if _label:
			update()

@onready var _label: Label = %Label


func _process(_delta: float):
	update()


func _input(event: InputEvent):
	if event.is_action_pressed("show_more_ui"):
		show_full = true
	elif event.is_action_released("show_more_ui"):
		show_full = false


func _stat_value_prettify(value: float) -> String:
	if show_full:
		return str("%.2f" % value)
	return str("%.1f" % value)


func update():
	if not Game.player.character:
		return
	
	var text := ""
	
	text += ("Урон: " if show_full else "У: ") + _stat_value_prettify(
		Game.player.character.stat_damage_ratio.value)
	text += "\n" + ("Броня: " if show_full else "Б: ") + _stat_value_prettify(
		Game.player.character.stat_armor.value)
	text += "\n" + ("Скорость: " if show_full else "С: ") + _stat_value_prettify(
		Game.player.character.stat_speed_ratio.value)
	text += "\n" + ("Скорострельность: " if show_full else "С: ") + _stat_value_prettify(
		Game.player.character.stat_shooting_speed.value)
	
	_label.text = text
