extends Node

class_name  UIAdapter

signal show_boss
signal update_health
signal remove_boss


var boss_name: String
var current_hp: int
var max_hp: int
var data_for_interface: BossUIData
