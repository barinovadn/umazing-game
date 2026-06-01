@icon("pickup_manager.png")
extends Node
class_name PickupManager

@export var pickup_prefab: PackedScene = preload("res://prefabs/inventory/pickups/pickup.tscn")


func spawn(item_data: ItemData, global_pos: Vector2) -> Pickup:
	if not pickup_prefab: return null
		
	var new_pickup = pickup_prefab.instantiate() as Pickup
	if not new_pickup:
		return null
		
	new_pickup.item_data = item_data.duplicate()
	new_pickup.global_position = global_pos
	
	add_child.call_deferred(new_pickup)

	return new_pickup
