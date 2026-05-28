@icon("ai_controller.png")
extends Area2D
class_name AIController


@export var character: Character2D
@export var deactivate_on_room_change: bool = true

@export_group("Combat")
@export var actions: Array[AIAction]
## Stores the HP percentage values (in the range of 0 to 1) at which the
## boss advances to the next phase. You need to record the HP percentage
## for each phase, starting with the second one. 
@export var modulates_for_phase: Array[float]
@export var movement_patterns: Dictionary[String, MovementController2D]
@export var modifier: Modifier

@export_group("VFX", "vfx")
@export var vfx_on_phase_change: VFXProfile

@export_group("Event Responses")
@export var show_on_activation: Array[Node2D]
@export var hide_on_activation: Array[Node2D]
@export var show_on_death: Array[Node2D]
@export var hide_on_death: Array[Node2D]
@export var tp_on_death: Node2D

@export_group("Interface")
@export var data_for_interface: BossContainerData
@export var interface_needed: bool = false

## Allows you to specify the [BossUI] location where the interface will be added.
## By default, it is displayed in the player's [BossUI].
@onready var display_location: BossUI = %Player/%BossUI
## A timer that sets the interval between actions
@onready var action_changer: Timer = $AIActionChanger


## Current boss movement pattern
var current_bullet_type: Resource
var current_phase: int = 0:
	set(value):
		if value == current_phase:
			return
		current_phase = clamp(value, 0, INF)
		_on_phase_changed()
		if vfx_on_phase_change:
			vfx_on_phase_change.spawn(global_position)
var hurt_component: HurtComponent
var shoot_controller: ShootController
var movement_controller: MovementController2D


func _ai_ready(): pass
func _on_action(_action: AIAction): pass
func _on_phase_changed(): pass
func _on_death(): pass


func _ready():
	if not character:
		character = get_parent() as Character2D
	character.deleted.connect(_set_target_point)
	character.hurt_component_changed.connect(attach_hurt_component)
	character.shoot_controller_changed.connect(attach_shoot_controller)
	character.movement_controller_changed.connect(attach_movement_controller)
	hurt_component = character.hurt_component
	shoot_controller = character.shoot_controller
	movement_controller = character.movement
	
	if hurt_component:
		hurt_component.health_changed.connect(_on_health_changed)
		hurt_component.fatal_damage_taken.connect(_on_fatal_damage_taken)
	
	current_phase = 1

	
	_ai_ready()


## Sets up portals associated with the boss. Disables the entrance portal,
## spawns an exit portal at the boss's death location, and activates it.
func _set_target_point():
	if tp_on_death:
		tp_on_death.global_position = hurt_component.global_position
	
	activate_points(show_on_death)
	deactivate_points(hide_on_death)


## Replaces the boss's action and plays it
func _on_action_changer_timeout():
	if shoot_controller:
		shoot_controller.stop_shooting()
	
	var ready_boss_actions: Array[AIAction] = _select_available_actions()
	var action_to_play: AIAction = _select_action_by_weight(ready_boss_actions)
	if action_to_play:
		movement_controller = movement_patterns[action_to_play.action_name]
		if shoot_controller:
			shoot_controller.set_bullet_array(action_to_play.bullet_types)
			shoot_controller.interval_between_shots = action_to_play.shoot_interval
			shoot_controller.post_shot_cd_interval = action_to_play.shooting_animation_interval
			shoot_controller.enabled = action_to_play.can_shoot
		if movement_controller:
			movement_controller.enabled = action_to_play.can_move
		
		_on_action(action_to_play)
		action_changer.start(action_to_play.duration)
		
	character.movement = movement_controller
	
	if shoot_controller and shoot_controller.enabled:
		if shoot_controller.on_shoot_cooldown:
			await shoot_controller.shooting_is_available
			shoot_controller.shoot.call_deferred()
		else:
			shoot_controller.shoot.call_deferred()


## Selects actions from the boss's set of available actions that are available in this phase
func _select_available_actions() -> Array[AIAction]:
	var ready_boss_actions: Array[AIAction]
	
	for action in actions:
		if current_phase in action.phases:
			ready_boss_actions.append(action)
	
	return ready_boss_actions


## Selects an action available in this phase
func _select_action_by_weight(ready_boss_actions: Array[AIAction]) -> AIAction:
	var array_length: float = 0.0
	
	for action in ready_boss_actions:
		array_length += action.weight
	
	var chance_of_action: float = randf_range(0, array_length)
	
	var current_length: float = 0.0
	var action_to_play: AIAction
	
	for action in ready_boss_actions:
		current_length += action.weight
		if chance_of_action <= current_length:
			action_to_play = action
			break
	
	if !action_to_play:
		return ready_boss_actions.pick_random() if ready_boss_actions else null
	
	return action_to_play


## Checks whether a phase change is necessary and, if the conditions are met, increases it
func _check_phase():
	if (current_phase < modulates_for_phase.size() + 1):
		var hp_for_phase_change: float = hurt_component.max_health * modulates_for_phase[current_phase-1]
		if (hurt_component.current_health <= hp_for_phase_change):
			current_phase += 1


func _on_health_changed(_amount: float):
	display_location.update(data_for_interface, self)
	_check_phase()


func _on_fatal_damage_taken():
	deactivate_interaction()
	
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	
	display_location.remove(data_for_interface)
	_on_death()


## Allows the boss to move, shoot, and select an action
func activate_interaction(_area: Area2D = null):
	activate_points(show_on_activation)
	deactivate_points(hide_on_activation)
	if interface_needed:
		display_location.add(data_for_interface, self)
	_on_action_changer_timeout()
	action_changer.start()
	Game.player.character.stat_cant_interract.add_modifier(var_to_str(modifier.get_instance_id()), modifier)
	Game.player.stat_cant_use_inventory.add_modifier(var_to_str(modifier.get_instance_id()), modifier)


## Prevents the boss from moving or shooting and selects an action
func deactivate_interaction(_area: Area2D = null):
	if (_area and not deactivate_on_room_change):
		return
	Game.player.stat_cant_use_inventory.remove_modifier(var_to_str(modifier.get_instance_id()))
	Game.player.character.stat_cant_interract.remove_modifier(var_to_str(modifier.get_instance_id()))
	action_changer.stop()
	if movement_controller:
		movement_controller.enabled = false
	if shoot_controller:
		shoot_controller.enabled = false
	if interface_needed:
		display_location.remove(data_for_interface)


func deactivate_points(points: Array[Node2D]):
	for point in points:
		point.visible = false
		point.process_mode = Node.PROCESS_MODE_DISABLED


func activate_points(points: Array[Node2D]):
	for point in points:
		point.visible = true
		point.process_mode = Node.PROCESS_MODE_INHERIT


func attach_hurt_component(component: HurtComponent):
	hurt_component = component


func attach_shoot_controller(controller: ShootController):
	shoot_controller = controller


func attach_movement_controller(movement: MovementController2D):
	movement_controller = movement
