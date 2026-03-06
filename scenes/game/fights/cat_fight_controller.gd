class_name CatFightController2D
extends FightController2D
## Enemy (cat) fight controller. Handles different attack patterns and shooting behavior.

# Possible movement directions (used for input mapping, though not fully utilized here).
enum Direction { LEFT, RIGHT, UP, DOWN }

# Available attack types.
enum Actions{
	STRAIGHT_SHOT,   # Shoots a single projectile directly at the player
	SINUSOID_SHOT,   # (commented out) Intended for wave‑like projectiles
	HOMING_SHOT,     # Shoots a homing projectile that tracks the player
	SPRAY_SHOT       # Shoots a spread of multiple projectiles
}

## Action names from [InputMap] mapped to movement directions.
## (Could be used to determine aiming direction, but currently the enemy aims at the player via sprite position.)
@export var fight_controls: Dictionary[Direction, String] = {
	Direction.LEFT: "ui_left",
	Direction.RIGHT: "ui_right",
	Direction.UP: "ui_up",
	Direction.DOWN: "ui_down",
	}

# Reference to the enemy's hurt component (handles taking damage and death).
var hurt_component: HurtComponent

# Constants for projectile scenes and speeds (some unused like SPEED, JUMP_VELOCITY).
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const PLAYER_PROJECTILE = preload("uid://ciwwaylcgm1fb")   # Possibly for player, not used here
const STONE_SHOT = preload("uid://1fs5fg40bjar")           # Straight projectile scene
const HOMING_SHOT = preload("uid://ccbamilt8pd75")         # Homing projectile scene

@export var cyclop_cat: Character2D                       # The enemy character itself
var enemy_controller: EnemyMovementController2D
@export var pause_between_shots: Timer    # Timer that controls delay between shots
@export var action_changer: Timer            # Timer that triggers switching attack pattern

# Variables for movement points (appear unused; possibly left from earlier implementation).
var movement_points
var current_movement_point

# Number of projectiles fired in a spray shot.
var spray_shot_count = 3
# Currently active attack pattern.
var current_action = Actions.STRAIGHT_SHOT
# Base angle offset for spray shots (in degrees). The spread will start from this angle.
var min_projectile_degree = -15

# Initialization function (not automatically called; maybe intended to be called externally).
func init():
	var random_point = movement_points.pick_random()
	current_movement_point = random_point.position

	pause_between_shots.setup()
	action_changer.setup()

func _ready():
	# Connect the hurt component's death signal to stop fighting.
	character_body = cyclop_cat.enemy
	enemy_controller = cyclop_cat.movement
	hurt_component = cyclop_cat.hurt_component
	hurt_component.died.connect(on_died)

func on_died():
	# Disable fighting when the enemy dies.
	fighting_enabled = false
	# The line below is commented out – possibly the death signal is emitted elsewhere.
	# cyclop_cat.died.emit()

# Returns the current health value (used by other scripts, e.g., UI).
func get_health():
	return hurt_component.heath

# Randomly picks an attack pattern (0 to 3 corresponding to Actions enum).
func pick_action():
	var rand_point: int = randi_range(0, 3) as Actions
	return rand_point

# Called when the pause_between_shots timer times out – performs a shot based on current_action.
func _on_pause_between_shots_timeout() -> void:
	if !fighting_enabled:
		return
	
	match current_action:
		Actions.STRAIGHT_SHOT:
			is_shooting = true
			# Set a short cooldown between shots.
			pause_between_shots.wait_time = 0.6
			shooting_started.emit()
			var projectile = STONE_SHOT.instantiate() as StoneProjectile
			
			# Calculate direction from enemy to player (sprite's global position).
			var to_target = character_body.global_position - cyclop_cat.global_position
			to_target = to_target.normalized()
			
			if to_target:
				projectile.direction = to_target
			else:
				projectile.direction = Vector2.RIGHT
			projectile.global_position = cyclop_cat.global_position

			get_tree().root.add_child(projectile)
		Actions.HOMING_SHOT:
			is_shooting = true
			pause_between_shots.wait_time = 1.2
			shooting_started.emit()
			var homing_shot = HOMING_SHOT.instantiate() as HomingProjectile
			homing_shot.set_target(character_body)   # Pass the player's sprite as the target
			homing_shot.global_position = cyclop_cat.global_position

			get_tree().root.add_child(homing_shot)
		Actions.SPRAY_SHOT:
			is_shooting = true
			pause_between_shots.wait_time = 1.2
			# Base direction towards the player.
			var to_target = character_body.global_position - cyclop_cat.global_position
			to_target = to_target.normalized()
			
			# Compute incremental changes for x and y to create a spread.
			# Note: This spread logic is simplistic and may not produce a visually even spread.
			var move_delta_x = (1 - to_target.x)/(spray_shot_count * 3)
			var move_delta_y = (1 - to_target.y)/(spray_shot_count * 3)
			
			for i in spray_shot_count:
				# Modify direction for each projectile in the spray.
				to_target.x += move_delta_x * i
				to_target.y += move_delta_y * i
				to_target = to_target.normalized()
				shooting_started.emit()
				var projectile = STONE_SHOT.instantiate() as StoneProjectile
				if to_target:
					projectile.direction = to_target
					# Also rotate the projectile sprite for visual spread.
					projectile.rotation_degrees = min_projectile_degree + 15 * i
				else:
					projectile.direction = Vector2.RIGHT
				projectile.global_position = cyclop_cat.global_position
				
				get_tree().root.add_child(projectile)
		# Actions.SINUSOID_SHOT:
			# (Commented out) Intended for wave‑like projectile pattern.
	await get_tree().create_timer(0.3).timeout
	is_shooting = false

# Called when the action_changer timer times out – switches to a new random attack pattern.
func _on_action_changer_timeout() -> void:
	current_action = pick_action()

# Placeholder functions (possibly intended for future use).
func get_direction():
	pass
	
func get_homing_direction():
	pass
