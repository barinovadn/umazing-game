class_name PlayerFightController2D
extends FightController2D
## Player shooting controller (inherits from base fight controller).
## Handles shooting input, projectile spawning, and reaction to player death.

# Movement directions, used for key binding (similar to movement controller).
enum Direction { LEFT, RIGHT, UP, DOWN }

# Preloaded player projectile scene (using unique identifier uid).
const PLAYER_PROJECTILE = preload("uid://ciwwaylcgm1fb")

# References to sibling nodes (found via relative path in the scene).
@onready var player_controller: PlayerMovementController2D = $"../PlayerController"   # Player movement controller
@onready var hurt_component: HurtComponent = $"../HurtComponent"                     # Damage handling component (needed for death signal)
@onready var ninja_green: Character2D = $".."                                        # Parent character (the player itself)

## Action names from [InputMap] mapped to movement directions.
## Used to determine the current aiming/shooting direction.
@export var fight_controls: Dictionary[Direction, String] = {
	Direction.LEFT: "ui_left",
	Direction.RIGHT: "ui_right",
	Direction.UP: "ui_up",
	Direction.DOWN: "ui_down",
}

func _ready():
	# Connect the death signal from the hurt component to our on_died function.
	if hurt_component:
		hurt_component.died.connect(on_died)

func _input(event: InputEvent) -> void:
	# If fighting is disabled (fighting_enabled inherited from FightController2D) — ignore input.
	if !fighting_enabled:
		return
	
	# Check if the shoot button (action "shoot") was just pressed and the player is not already shooting.
	if Input.is_action_just_pressed("shoot") && !is_shooting:
		is_shooting = true   # set flag to prevent multiple calls
		shoot()              # spawn the projectile

# Called when the player dies (died signal from HurtComponent).
func on_died():
	# Disable movement so the player cannot move after death.
	player_controller.movement_enabled = false
	# The line below is commented out: possibly the death signal emission has been moved elsewhere.
	# ninja_green.died.emit()

# Spawns and launches the player's projectile.
func shoot():
	shooting_started.emit()   # notify other parts of the game that shooting has begun (e.g., for animations)
	
	# Instantiate the projectile and cast it to PlayerProjectile type.
	var projectile = PLAYER_PROJECTILE.instantiate() as PlayerProjectile

	# Determine the projectile's flight direction.
	# The variable direction is likely inherited from FightController2D and
	# updated based on pressed keys (fight_controls).
	if direction:
		projectile.direction = direction
	else:
		# If no direction is set — shoot to the right by default.
		projectile.direction = Vector2.RIGHT
	
	# Set the projectile's position to the player's position (character_body from FightController2D).
	projectile.global_position = character_body.global_position
	
	# Add the projectile to the scene root so it exists independently of the player.
	get_tree().root.add_child(projectile)

	# Wait 0.3 seconds (simulating cooldown), then reset the is_shooting flag.
	await get_tree().create_timer(0.3).timeout
	is_shooting = false
