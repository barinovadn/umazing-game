class_name EnemyMovementController2D

extends MovementController2D
## Enemy movement controller that randomly moves between predefined points.
## Inherits from MovementController2D and uses a set of target points (children of a node)
## to navigate the enemy. When close enough to a target, it picks a new random one.

# Reference to the node containing all movement points (children are Marker2D or similar).
var enemy : Character2D
@export var enemy_movement_points: Node 
# Reference to the hurt component to detect when the enemy dies.
var hurt_component: HurtComponent 

# List of all movement point nodes (children of enemy_movement_points).
var movement_points: Array
# The current target position (global coordinates) the enemy is moving towards.
var current_movement_point: Vector2
# The normalized direction vector towards the current target.
var move_direction: Vector2



func _ready():
	enemy = character_body
	# Gather all child nodes of the movement points container.
	movement_points = enemy_movement_points.get_children()
	hurt_component = enemy.hurt_component
	# Choose the first random target.
	pick_new_target()
	# Connect the death signal to stop movement when the enemy dies.
	hurt_component.died.connect(on_cat_died)
	movement_enabled = character_body.movement.movement_enabled

# Randomly selects a new target point from the movement_points list.
func pick_new_target():
	if movement_points.is_empty():
		return
	var random_point = movement_points.pick_random()
	current_movement_point = random_point.global_position

func _physics_process(_delta):
	# If movement is disabled (e.g., after death), do nothing.
	if not movement_enabled:
		return
	
	var current_pos = character_body.global_position
	var distance_sq = current_pos.distance_squared_to(current_movement_point)
	
	# If the enemy is very close to the target (within ~20 pixels), pick a new one.
	if distance_sq < 400.0:  # threshold = 20^2
		pick_new_target()
		# Recalculate direction toward the new target.
		var to_target = current_movement_point - current_pos
		if to_target.length_squared() > 0:
			move_direction = to_target.normalized()
		else:
			move_direction = Vector2.ZERO
	else:
		# Otherwise, continue moving toward the current target.
		var to_target = current_movement_point - current_pos
		move_direction = to_target.normalized()
	
	# If we have a valid direction, move; otherwise stop.
	if move_direction != Vector2.ZERO:
		move(movement_speed, move_direction)
	else:
		stop()
	
	# Apply the movement by calling move_and_slide() on the character body.
	character_body.move_and_slide()

# Called when the enemy's hurt component emits the died signal.
func on_cat_died():
	# Disable movement so the enemy stops moving after death.
	movement_enabled = false
