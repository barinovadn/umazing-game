extends Bullet

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.play("player_shot")
	team = CombatScript.team.player
	crit_damage = 1
	crit_chance = 0.1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !direction:
		direction_needed.emit()
		return
	position += direction * speed * delta
