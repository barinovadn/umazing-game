extends CanvasLayer

class_name UI

@export var boss_name: Label
@export var cyclop_cat: Character2D
@export var ninja_green: Character2D
@export var label: Label
@export var game_lost_container: CenterContainer
@export var hero_hb: ProgressBar 
@export var boss_hb: ProgressBar
@export var boss_name_text: String
@export var exit_portal: Teleport

var player_win: bool
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
	player_win = true
	
	label.text = "You've Won!"
	
	exit_portal.global_position = cyclop_cat.global_position
	
	game_lost_container.show()
	cyclop_cat.fight.fighting_enabled = false
	cyclop_cat.died.emit()

func on_player_died():
	player_win = false
	hero_hb.value = hurt_component.heath
	label.text = "You've Lost!"
	ninja_green.died.emit()
	game_lost_container.show()

func _on_button_pressed() -> void:
	visible = false
	if player_win:
		exit_portal.visible = true
		exit_portal.monitorable = true
		exit_portal.monitoring = true
	else:
		SceneManager.redraw_current_scene()
