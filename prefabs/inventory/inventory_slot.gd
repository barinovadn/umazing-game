class_name InventorySlot
extends Button


signal item_selected(data: ItemData)

@export_group("Selection", "selection")
@export var selection_active_modulate: Color = Color.WHITE
@export var selection_default_modulate: Color = Color.WHITE

@onready var icon_rect: TextureRect = $HBox/Icon
@onready var name_label: Label = $HBox/Name
@onready var amount_label: Label = $HBox/Amount
@onready var background: ColorRect = $BG


var is_selected: bool:
	set(value):
		is_selected = value
		
		if is_selected:
			grab_focus()
			item_selected.emit(item_data)
			background.modulate = selection_active_modulate
		else:
			background.modulate = selection_default_modulate
var item_data: ItemData = null


func set_item(data: ItemData):
	item_data = data

	if data and is_instance_valid(data):
		name_label.text = data.name
		icon_rect.texture = data.icon
		icon_rect.show()
		if data.is_stackable and data.amount > 1:
			amount_label.text += str(data.amount)
			amount_label.show()
		else:
			amount_label.hide()
	else:
		name_label.text = "Пусто"
		icon_rect.texture = null
		icon_rect.hide()


func select():
	is_selected = true


func _on_pressed():
	select()
