class_name InventoryUI
extends Node

@export var slot_scene: PackedScene = preload("res://prefabs/inventory/inventory_slot.tscn")

@export_group("Sounds", "sound")
@export var sound_use: AudioStream = preload("res://prefabs/inventory/inventory_item_drop.ogg")
@export var sound_drop: AudioStream = preload("res://prefabs/inventory/inventory_item_use.ogg")

@onready var item_list = $VBox/Scroll/ItemList
@onready var action_panel = $VBox/ActionPanel
@onready var use_button = $VBox/ActionPanel/UseButton
@onready var info_button = $VBox/ActionPanel/InfoButton
@onready var drop_button = $VBox/ActionPanel/DropButton
@onready var inventory_logic = %Inventory
@onready var inventory_ui = %UI/InventoryUI
@onready var sfx_player = $AudioStream

var selected_item: String = "":
	set(value):
		selected_item = value
		# FIXME No local storage var for the active ui item slots
		for node in item_list.get_children():
			var item_slot := node as InventorySlot
			if not item_slot:
				continue
			item_slot.is_selected = item_slot.item_data.name == selected_item
var can_open_inventory: bool = true:
	set(value):
		can_open_inventory = value
		if not can_open_inventory:
			close()


func _ready():
	action_panel.hide()
	inventory_ui.hide()
	
	if inventory_logic:
		inventory_logic.updated.connect(refresh_ui)


func _input(event):
	if event.is_action_pressed("inventory"):
		if !can_open_inventory:
			return
		inventory_ui.visible = !inventory_ui.visible
		_on_inventory_status_changed()


func _on_inventory_status_changed():
	var player_char := Game.player.character
	
	if inventory_ui.visible:
		player_char.stat_cant_shoot.add_modifier("INVENTORY")
		player_char.stat_cant_move.add_modifier("INVENTORY")
		player_char.stat_cant_interract.add_modifier("INVENTORY")
	
	else:
		player_char.stat_cant_interract.remove_modifier("INVENTORY")
		player_char.stat_cant_move.remove_modifier("INVENTORY")
		player_char.stat_cant_shoot.remove_modifier("INVENTORY")
		
		inventory_ui.action_panel.hide()


func _on_slot_selected(item_name: String):
	selected_item = item_name
	var item_data = inventory_logic.get_item(item_name)
	setup_action_panel(item_data)


func _on_use_button_pressed():
	if selected_item:
		inventory_logic.use_item(selected_item)
		play_sound(sound_use)
		selected_item = ""
		action_panel.hide()


func _on_info_button_pressed():
	if selected_item:
		var item := inventory_logic.get_item(selected_item) as ItemData
		if len(item.description):
			Game.dialogue_system.display(item.description.pick_random())


func _on_drop_button_pressed():
	if selected_item:
		inventory_logic.remove_item(selected_item)
		play_sound(sound_drop)
		selected_item = ""
		action_panel.hide()


func open():
	if !can_open_inventory:
		return
	inventory_ui.visible = true
	_on_inventory_status_changed()


func close():
	inventory_ui.visible = false
	_on_inventory_status_changed()


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


func play_sound(stream: AudioStream):
	if sfx_player and stream:
		sfx_player.stream = stream
		sfx_player.play()
