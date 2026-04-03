extends Bullet

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: Player = %Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.play("stone_shot")
	bullet_enemy = player.character
	team = CombatScript.team.enemy
	direction = (bullet_enemy.global_position - animated_sprite_2d.global_position).normalized()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !bullet_enemy:
		direction = Vector2.LEFT
	if !direction:
		direction = Vector2.LEFT
	position += direction * speed * delta
