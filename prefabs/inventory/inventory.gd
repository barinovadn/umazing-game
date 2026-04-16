class_name Inventory
extends Node

@export var slot_scene: PackedScene

@onready var item_list = $VBoxContainer/ScrollContainer/ItemList
@onready var action_panel = $VBoxContainer/ActionPanel

var selected_slot = null
var items_count = 0

func _ready():
	action_panel.hide()


func add_item(data: ItemData):
	if not data: return
	if items_count >= 7: return false
	var new_slot = slot_scene.instantiate()
	item_list.add_child(new_slot)
	new_slot.set_item(data)

	new_slot.item_selected.connect(_on_slot_selected)
	items_count += 1
	return true


func use_selected_item():
	if not selected_slot or not selected_slot.item_data:
		return
		
	var item = selected_slot.item_data
	print("Использован: ", item.item_name)

	if item.is_consumable:
		remove_selected_item()


func remove_selected_item():
	if selected_slot:
		selected_slot.queue_free()
		selected_slot = null
		action_panel.hide()


func _on_info_requested():
	if selected_slot and selected_slot.item_data:
		print("Описание: ", selected_slot.item_data.description)


func _on_slot_selected(data: ItemData, slot_ref):
	selected_slot = slot_ref
	
	action_panel.setup_for_item(data)
	
	if not action_panel.use_button.disabled:
		action_panel.use_button.grab_focus()
	else:
		action_panel.info_button.grab_focus()
