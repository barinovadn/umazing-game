@icon("inventory.png")
class_name Inventory
extends Node2D


signal updated
signal full
signal item_added(item: ItemData, amount: int)
signal item_removed(item: ItemData)
signal item_amount_changed(item: ItemData)
signal item_used(item: ItemData)

@export var capacity: int = 7

@export_subgroup("Notifications", "vfx_notification")
@export var vfx_notification_inventory_full: VFXProfile
@export var vfx_notification_item_added: VFXProfile
@export var vfx_notification_item_used: VFXProfile

var items: Array[ItemData] = []


func _ready():
	for loaded_item in SaveManager.loaded_items:
		add_item(loaded_item)
	updated.emit.call_deferred()

func _get_stackable_item(item_name: String):
	for item in items:
		if item.name == item_name and item.amount < item.max_stack:
			return item
	return null


func _fill_existing_stacks(data: ItemData, amount: int) -> int:
	for item in items:
		if item.name == data.name and item.amount < data.max_stack:
			var can_add = data.max_stack - item.amount
			var adding = min(amount, can_add)
			item.amount += adding
			item._on_item_added_to_inventory()
			item_added.emit(item, adding)
			amount -= adding
			if amount <= 0:
				break
	return amount


func _on_item_added(item: ItemData, amount: int):
	if vfx_notification_item_added:
		vfx_notification_item_added.settings.notification_text = (
			"+"
			+ ( (str(amount) + " ") if amount > 1 else "" )
			+ item.name
		)
		if Game.player and is_instance_valid(Game.player):
			vfx_notification_item_added.spawn(Game.player.character.global_position)


func _on_item_used(item: ItemData):
	if vfx_notification_item_added:
		vfx_notification_item_added.settings.notification_text = "-" + item.name
		vfx_notification_item_added.spawn(Game.player.character.global_position)


func get_item(item_name: String) -> ItemData:
	for i in range(items.size() -1, -1, -1):
		if items[i].name == item_name:
			return items[i]
	return null


func get_item_amount(item_name: String) -> int:
	var item = get_item(item_name)
	return item.amount if item else 0


func add_item(data: ItemData) -> int:
	var remaining = data.amount
	
	remaining = _fill_existing_stacks(data, remaining)
	
	while remaining > 0 and items.size() < capacity:
		var add_amount = min(remaining, data.max_stack)
		var new_item = data.duplicate()
		new_item.amount = add_amount
		
		items.append(new_item)
		item_added.emit(new_item, new_item.amount)
		new_item._on_item_added_to_inventory()
		remaining -= add_amount
	
	if remaining < data.amount:
		updated.emit()

	if remaining > 0:
		full.emit()
		if vfx_notification_inventory_full:
			vfx_notification_inventory_full.spawn(global_position)
	
	return remaining


func remove_item(item_name: String, amount: int = 1) -> bool:
	if get_item_amount(item_name) < amount:
		return false
	
	var remaining = amount
	while remaining > 0:
		var item = get_item(item_name)
		if not item: break
	
		var index = items.find(item)
	
		if item.amount > remaining:
			item.amount -= remaining
			remaining = 0
			item_amount_changed.emit(item)
		else:
			remaining -= item.amount
			items.remove_at(index)
			item_removed.emit(item)
			item._on_item_removed_to_inventory()
	
	updated.emit()
	return true


func use_item(item_name: String):
	var item = get_item(item_name)
	if not item:
		return
	
	item.use()
	item_used.emit(item)
	Game.player.inventory_ui.close()
	
	if item.is_consumable:
		remove_item(item_name)


func has_item(item_name: String, amount_required: int = 1) -> bool:
	return get_item_amount(item_name) >= amount_required


func has_free_space(item_name: String) -> bool:
	var item = get_item(item_name)
	
	if item and item.is_stackable and item.amount < item.max_stack:
		return true
	
	return items.size() < capacity


func clear():
	items.clear()
	updated.emit()
