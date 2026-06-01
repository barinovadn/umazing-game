extends Control
class_name BossUI


const BOSS_CONTAINER = preload("uid://dn3pwb4lu7m8l")

var target: Control = self
var containers: Dictionary[String, BossContainerUI]


func add(data: BossContainerData, controller: AIController):
	if containers.has(data.display_name):
		return
	
	var container := BOSS_CONTAINER.instantiate() as BossContainerUI
	
	target.add_child(container)
	containers[data.display_name] = container
	update(data, controller)


func update(data: BossContainerData, controller: AIController):
	if not data or not containers.has(data.display_name):
		return
	containers[data.display_name].update(data, controller)


func remove(data: BossContainerData):
	if not data or not containers.has(data.display_name):
		return
	
	containers[data.display_name].delete()
	containers.erase(data.display_name)
