@icon("player.png")
class_name Player
extends Node

signal character_changed(new_character: Character2D, old_character: Character2D)

@export var character: Character2D:
	set(value):
		if value == character:
			return
		var old_character = character
		character = value
		character_changed.emit(character, old_character)
@export var bullets: Dictionary[String, PackedScene]
@export var allow_cheats: bool = false

@export_group("Restrictions", "stat")
@export var stat_cant_use_inventory: Stat:
	set(value):
		if stat_cant_use_inventory:
			stat_cant_use_inventory.value_changed.disconnect(_on_block_inventory_changed)
		stat_cant_use_inventory = value
		if stat_cant_use_inventory and !stat_cant_use_inventory.value_changed.is_connected(_on_block_inventory_changed):
			stat_cant_use_inventory.value_changed.connect(_on_block_inventory_changed)

@onready var components: Node2D = $Components

@onready var shoot_controller: ShootController = %ShootController
@onready var hurt_component: HurtComponent = %HurtComponent
@onready var movement: MovementController2D = %Movement
@onready var interactor: Interactor = %Interactor
@onready var inventory: Inventory = %Inventory
@onready var reflection: Area2D = $Components/Reflection

@onready var trigger: Area2D = %Center
@onready var room: Area2D = %Room
@onready var cursor: Area2D = %Cursor
@onready var pickup_area: Node2D = %Picker

@onready var camera: GridCamera2D = %Camera
@onready var camera_controller: GridCameraFollower2D = %Camera/BehaviorFollow
@onready var camera_transitioner: GridCameraTransitionFade = %Camera/TransitionFade

@onready var env_particles: EnvironmentParticles = %EnvironmentParticles
@onready var env_filter: EnvironmentFilter = %EnvironmentFilter

@onready var inventory_ui: InventoryUI = %InventoryUI
@onready var health_ui: HealthUI = %HealthUI
@onready var boss_ui: BossUI = %BossUI
@onready var actions_ui: ActionsUI = %ActionsUI
@onready var stats_ui: StatsUI = %StatsUI

var noclip: bool:
	set(value):
		noclip = value
		character.collision = !noclip
		character.movement.speed *= (2. if noclip else .5)
var playtime: float:
	set(value):
		if not actions_ui:
			return
		actions_ui.total_playtime = value
	get(): return actions_ui.total_playtime if actions_ui else 0.0


func _ready():
	_on_character_changed(character, null)
	_load_stats()
	health_ui.update_health(hurt_component.current_health, hurt_component.max_health)


func _process(_delta: float):
	_update_component_positions()
	_update_cursor_position()


func _input(event: InputEvent):
	if not character:
		return
	
	var mouse_pos := character.get_global_mouse_position()
	var player_pos := character.global_position
	var new_dir := player_pos.direction_to(mouse_pos)
	
	if Input.is_action_pressed("mouse_interact"):
		character.direction = new_dir
		if not movement.is_moving:
			movement.direction = new_dir
	else:
		character.direction = Vector2.ZERO
	
	if Input.is_action_pressed("shoot"):
		shoot_controller.shoot()
	else:
		shoot_controller.stop_shooting()
	
	if event.is_action_released("mouse_interact"):
		interactor.interact.call_deferred()
		return
		
	if event.is_action_pressed("reflect"):
		reflection.enable()
		return
	
	if event.is_action_pressed("noclip") and allow_cheats:
		noclip = !noclip


## Some components like [member interactor] are expected to be children to the
## [member character] directily. This func syncs their positions with the
## [member character] to avoid that.
func _update_component_positions():
	if not character:
		return
	
	components.global_position = character.global_position


func _update_cursor_position():
	cursor.global_position = components.get_global_mouse_position()


func _load_stats():
	if not character:
		return
	
	await get_tree().process_frame
	
	# HEALTH
	if SaveManager.loaded_max_hp > 0:
		character.hurt_component.sounds_mute = true
		character.hurt_component.vfx_mute = true
		character.hurt_component.max_health = SaveManager.loaded_max_hp
		character.hurt_component.current_health = SaveManager.loaded_hp
		character.hurt_component.sounds_mute = false
		character.hurt_component.vfx_mute = false
	
	# SPEED
	for modifier_id in SaveManager.loaded_speed_modifiers:
		character.stat_speed_ratio.add_modifier(modifier_id,
			 SaveManager.loaded_speed_modifiers[modifier_id])
	
	# ARMOR
	for modifier_id in SaveManager.loaded_armor_modifiers:
		character.stat_armor.add_modifier(modifier_id,
			 SaveManager.loaded_armor_modifiers[modifier_id])
	
	# DAMAGE
	for modifier_id in SaveManager.loaded_damage_modifiers:
		character.stat_shooting_speed.add_modifier(modifier_id,
			 SaveManager.loaded_damage_modifiers[modifier_id])
	
	# SHOOT SPEED
	for modifier_id in SaveManager.loaded_shoot_speed_modifiers:
		character.stat_shooting_speed.add_modifier(modifier_id,
			 SaveManager.loaded_shoot_speed_modifiers[modifier_id])
	
	# PLAYTIME
	playtime = SaveManager.loaded_playtime


func _on_character_changed(new_character: Character2D, old_character: Character2D):
	if old_character:
		old_character.movement = null
		old_character.interactor = null
		old_character.shoot_controller = null
		old_character.hurt_component = null
		old_character.hurt_component.character = null
	if new_character:
		new_character.movement = movement
		new_character.interactor = interactor
		new_character.shoot_controller = shoot_controller
		if new_character.shoot_controller:
			for el in bullets.values():
				new_character.shoot_controller.bullets.append(el)
		new_character.hurt_component = hurt_component
		if new_character.hurt_component:
			new_character.hurt_component.character = new_character
		
	if camera_controller:
		camera_controller.target = new_character


func _on_health_changed(_amount: float = 0.0):
	if hurt_component:
		health_ui.update_health(hurt_component.current_health, hurt_component.max_health)


func _on_fatal_damage_taken():
	get_tree().reload_current_scene.call_deferred()


func _on_camera_cell_changed(new_cell: Vector2, _smooth_transition: bool):
	if room:
		room.global_position = camera.grid_size * new_cell


func _on_pickup_found(body: Node2D):
	var pickup := body as Pickup
	
	if not pickup:
		return
	
	pickup.collect(inventory)


func _on_block_inventory_changed():
	if inventory_ui:
		inventory_ui.can_open_inventory = not stat_cant_use_inventory.value
