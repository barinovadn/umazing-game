class_name VFXEffectNotification2D
extends VFXEffect2D


@onready var _label: Label = %Label


func _on_settings_applied():
	_label.text = settings.notification_text
	_label.add_theme_color_override("font_color", settings.notification_text_color)
