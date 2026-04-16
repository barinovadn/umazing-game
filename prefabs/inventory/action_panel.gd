extends HBoxContainer

signal use_pressed
signal info_pressed
signal drop_pressed

@onready var use_button = $UseButton
@onready var info_button = $InfoButton
@onready var drop_button = $DropButton


func setup_for_item(item: ItemData):
	if item:
		if item.item_type == "Passive":
			use_button.disabled = true
			use_button.focus_mode = Control.FOCUS_NONE 
		else:
			use_button.disabled = false	
			use_button.focus_mode = Control.FOCUS_ALL
			
		self.show()
	else:
		self.hide()


func _on_use_button_pressed():
	use_pressed.emit()


func _on_info_button_pressed():
	info_pressed.emit()


func _on_drop_button_pressed():
	drop_pressed.emit()
