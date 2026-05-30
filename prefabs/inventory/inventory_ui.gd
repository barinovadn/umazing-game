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

@export var modifier: Modifier
var can_open_inventory: bool = true

var selected_item: String = "":
	set(value):
		selected_item = value
		# FIXME No local storage var for the active ui item slots
		for node in item_list.get_children():
			var item_slot := node as InventorySlot
			if not item_slot:
				continue
			item_slot.is_selected = item_slot.item_data.name == selected_item


func _ready():
	action_panel.hide()
	inventory_ui.hide()
	
	if inventory_logic:
		inventory_logic.updated.connect(refresh_ui)


func _input(event):
	if event.is_action_pressed("inventory"):
		if !can_open_inventory:
			return
		
		Game.player.character.stat_cant_shoot.add_modifier(var_to_str(modifier.get_instance_id()), modifier)
		Game.player.character.stat_cant_move.add_modifier(var_to_str(modifier.get_instance_id()), modifier)
		Game.player.character.stat_cant_interract.add_modifier(var_to_str(modifier.get_instance_id()), modifier)
		
		inventory_ui.visible = !inventory_ui.visible
		
		## WARNING FIXME NOTE TODO TEMP SOLUTION
		#Game.player.interactor.enabled = !inventory_ui.visible
		#Game.player.shoot_controller.enabled = !inventory_ui.visible
		#Game.player.movement.enabled = !inventory_ui.visible
		if not inventory_ui.visible:
			Game.player.character.stat_cant_interract.remove_modifier(var_to_str(modifier.get_instance_id()))
			Game.player.character.stat_cant_move.remove_modifier(var_to_str(modifier.get_instance_id()))
			Game.player.character.stat_cant_shoot.remove_modifier(var_to_str(modifier.get_instance_id()))
			inventory_ui.action_panel.hide()


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


func play_sound(stream: AudioStream):
	if sfx_player and stream:
		sfx_player.stream = stream
		sfx_player.play()
