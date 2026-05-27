extends Character2D


@export var pet_owner: Node2D
@export var pet_owner_inspectable: Inspectable
@export var pet_owner_distance_required: float = 75.0
@export var owner_reaction: Array[Dialogue]
@export var owner_reaction_mode: Inspectable.Mode
@export var owner_reaction_order: Inspectable.Order


func _on_behaviour_follow_moved(_direction: Vector2, _speed: float):
	if not pet_owner:
		return
	
	if global_position.distance_to(pet_owner.global_position) <= pet_owner_distance_required:
		$BehaviourFollow.target = pet_owner
		
		pet_owner_inspectable.dialogues = owner_reaction
		pet_owner_inspectable.mode = owner_reaction_mode
		pet_owner_inspectable.order = owner_reaction_order
		pet_owner_inspectable.inspect()
		
		await get_tree().create_timer(5).timeout
		movement.enabled = false
