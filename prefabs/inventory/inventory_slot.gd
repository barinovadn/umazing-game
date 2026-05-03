extends Button


signal item_selected(data: ItemData)

@onready var icon_rect = $HBox/Icon
@onready var name_label = $HBox/Name
@onready var amount_label = $HBox/Amount

var is_selected: bool:
	set(value):
		is_selected = value
		
		if is_selected:
			grab_focus()
			item_selected.emit(item_data)
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
