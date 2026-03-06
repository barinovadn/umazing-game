extends CanvasLayer

class_name UI

@export var cyclop_cat: Character2D
@export var ninja_green: Character2D 
@onready var label: Label = $MarginContainer/GameLostContainer/Panel/VBoxContainer/Label
@onready var game_lost_container: CenterContainer = $MarginContainer/GameLostContainer
@onready var hero_hb: ProgressBar = $MarginContainer/HeroHB
@onready var boss_hb: ProgressBar = $MarginContainer/BossHB

var hurt_component: HurtComponent
var hurt_component_cat: HurtComponent

func _ready() -> void:
	hurt_component = ninja_green.hurt_component
	hurt_component_cat = cyclop_cat.hurt_component
	hurt_component.died.connect(on_player_died)
	hurt_component_cat.died.connect(on_boss_died)
	hurt_component.damaged.connect(on_player_damaged)
	hurt_component_cat.damaged.connect(on_boss_damaged)
	set_initial_health()

func set_initial_health():
	hero_hb.max_value = hurt_component.heath
	boss_hb.max_value = hurt_component_cat.heath

func decrease_player_health(current_health):
	hero_hb.value = current_health

func decrease_enemy_health(current_health):
	hero_hb.value = current_health

func on_boss_damaged():
	boss_hb.value = hurt_component_cat.heath
	
func on_player_damaged():
	hero_hb.value = hurt_component.heath

func on_boss_died():
	boss_hb.visible = false
	label.text = "You've Won!"
	game_lost_container.show()
	cyclop_cat.fight.fighting_enabled = false
	cyclop_cat.animation_died()

func on_player_died():
	hero_hb.value = hurt_component.heath
	label.text = "You've Lost!"
	game_lost_container.show()

func _on_button_pressed() -> void:
	ninja_green.change_scene()
