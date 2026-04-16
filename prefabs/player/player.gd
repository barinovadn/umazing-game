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

@onready var controller: MovementController2D = $Controller
@onready var interactor: Interactor = $Interactor
@onready var trigger: Node2D = $Trigger
@onready var pickup_area: Node2D = $PickUp
@onready var camera: GridCamera2D = %Camera
@onready var camera_controller: GridCameraFollower2D = $Camera/BehaviorFollow
@onready var camera_transitioner: GridCameraTransitionFade = $Camera/TransitionFade
@onready var inventory: Inventory = $UI/Inventory


func _ready():
	_on_character_changed(character, null)
	## TODO Move to inventory (isolate logic)
	if inventory:
		inventory.hide()


func _process(_delta: float):
	_update_component_positions()


## Some components like [member interactor] are expected to be children to the
## [member character] directily. This func syncs their positions with the
## [member character] to avoid that.
func _update_component_positions():
	if not character:
		return
	
	interactor.global_position = character.global_position
	trigger.global_position = character.global_position
	pickup_area.global_position = character.global_position


## TODO Move to inventory (isolate logic)
func _input(event):
	if event.is_action_pressed("inventory"): 
		inventory.visible = !inventory.visible
		
		if inventory.visible:
			inventory.grab_focus() 
		else:
			inventory.action_panel.hide()


func _on_character_changed(new_character: Character2D, old_character: Character2D):
	if old_character:
		old_character.movement = null
		old_character.interactor = null
	
	if new_character:
		new_character.movement = controller
		new_character.interactor = interactor
	
	if camera_controller:
		camera_controller.target = new_character
