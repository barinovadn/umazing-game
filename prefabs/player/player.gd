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
@export var bullets: Array[PackedScene]
@export var allow_cheats: bool = false

var noclip: bool:
	set(value):
		noclip = value
		character.collision = !noclip
		character.movement.speed *= (2. if noclip else .5)

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


func _ready():
	_on_character_changed(character, null)
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
	
	if event.is_action_released("mouse_interact"):
		interactor.interact.call_deferred()
		return
		
	if event.is_action_pressed("reflect"):
		reflection.enable()
		return
	
	if event.is_action_pressed("shoot"):
		shoot_controller.shoot()
		return
		
	if event.is_action_released("shoot"):
		shoot_controller.stop_shooting()
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
	
	pickup.collect()
