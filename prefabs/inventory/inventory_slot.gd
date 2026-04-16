extends Button

signal item_selected(data, slot_ref)

@onready var icon_rect = $HBoxContainer/TextureRect
@onready var name_label = $HBoxContainer/Label 

var item_data: ItemData = null

func set_item(data: ItemData):
	item_data = data

	if data and is_instance_valid(data):
		name_label.text = data.item_name
		icon_rect.texture = data.item_icon
		icon_rect.show()
	else:
		name_label.text = "Пусто"
		icon_rect.texture = null
		icon_rect.hide()


func _on_pressed():
	item_selected.emit(item_data, self)
	grab_focus()
