extends Node


@export var slot_scene: PackedScene = preload("res://prefabs/inventory/inventory_slot.tscn")

@onready var item_list = $VBox/Scroll/ItemList
@onready var action_panel = $VBox/ActionPanel
@onready var use_button = $VBox/ActionPanel/UseButton
@onready var info_button = $VBox/ActionPanel/InfoButton
@onready var drop_button = $VBox/ActionPanel/DropButton
@onready var inventory_logic = %Inventory

var selected_item: String = ""


func _ready():
	action_panel.hide()
	if inventory_logic:
		inventory_logic.updated.connect(refresh_ui)


func setup_action_panel(item: ItemData):
	if item:
		if not item.is_active:
			use_button.disabled = true
			use_button.focus_mode = Control.FOCUS_NONE
		else:
			use_button.disabled = false
			use_button.focus_mode = Control.FOCUS_ALL
		action_panel.show()
	else:
		action_panel.hide()


func refresh_ui():
	for child in item_list.get_children():
		child.queue_free()
	
	for i in range(inventory_logic.items.size()):
		var item_data = inventory_logic.items[i]
		var new_slot = slot_scene.instantiate()
		item_list.add_child(new_slot)
		new_slot.set_item(item_data)
		new_slot.pressed.connect(_on_slot_selected.bind(item_data.name))


func _on_slot_selected(item_name: String):
	selected_item = item_name
	var item_data = inventory_logic.get_item(item_name)
	setup_action_panel(item_data)

	if not use_button.disabled:
		use_button.grab_focus()
	else:
		info_button.grab_focus()


func _on_use_button_pressed():
	if selected_item:
		inventory_logic.use_item(selected_item)
		selected_item = ""
		action_panel.hide()


func _on_info_button_pressed():
	if selected_item:
		var item = inventory_logic.get_item(selected_item)
		print("Инфа о предмете: ", item.description)


func _on_drop_button_pressed():
	if selected_item:
		inventory_logic.remove_item(selected_item)
		selected_item = ""
		action_panel.hide()
