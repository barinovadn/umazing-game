extends Control
class_name BossUI


@onready var boss_hp_container: VBoxContainer = $BossHPContainer
@onready var boss_name_container: VBoxContainer = $BossNameContainer
const TINY_5_REGULAR = preload("uid://c7b6uwmntv2d7")

# дефолт текстуры
@export var default_under: Texture2D
@export var default_progress: Texture2D
@export var default_over: Texture2D

# name → { bar, label }
var active_bars: Dictionary = {}


func _ready() -> void:
	UiAdapter.show_boss.connect(on_show_boss)
	UiAdapter.update_health.connect(on_update_health)
	UiAdapter.remove_boss.connect(on_remove_boss)

# показать босса
func show_boss(boss_name: String, current_hp: int, max_hp: int, data: BossUIData = null):
	if active_bars.has(boss_name):
		return

	var bar := TextureProgressBar.new()
	var label := Label.new()

	label.text = boss_name
	label.add_theme_font_override("font", TINY_5_REGULAR)
	
	if data:
		bar.texture_under = data.texture_under
		bar.texture_progress = data.texture_progress
		bar.texture_over = data.texture_over
	else:
		bar.texture_under = default_under
		bar.texture_progress = default_progress
		bar.texture_over = default_over
	
	bar.max_value = max_hp
	bar.value = current_hp
	
	bar.custom_minimum_size = Vector2(400, 16)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	boss_hp_container.add_child(bar)
	boss_name_container.add_child(label)

	active_bars[boss_name] = {
		"bar": bar,
		"label": label
	}

	visible = true


# обновить HP
func update_health(name_b: String, current_hp: int, max_hp: int):
	if not active_bars.has(name_b):
		return

	var bar: TextureProgressBar = active_bars[name_b]["bar"]

	bar.max_value = max_hp
	bar.value = current_hp


# убрать босса
func remove_boss(name_b: String):
	if not active_bars.has(name_b):
		return

	var bar = active_bars[name_b]["bar"]
	var label = active_bars[name_b]["label"]

	bar.queue_free()
	label.queue_free()

	active_bars.erase(name_b)

	if active_bars.is_empty():
		visible = false


func on_show_boss():
	show_boss(UiAdapter.boss_name, UiAdapter.current_hp, UiAdapter.max_hp, UiAdapter.data_for_interface)


func on_remove_boss():
	remove_boss(UiAdapter.boss_name)


func on_update_health():
	update_health(UiAdapter.boss_name, UiAdapter.current_hp, UiAdapter.max_hp)
