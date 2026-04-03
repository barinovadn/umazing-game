extends Bullet

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var player: Player = %Player
var can_aim = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite_2d.play("homing_shot")
	team = CombatScript.team.enemy
	bullet_enemy = player.character

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !bullet_enemy:
		print("Eror")
		return
	if can_aim:
		direction = (bullet_enemy.global_position - animated_sprite_2d.global_position).normalized()
	position += direction * speed * delta

func _on_timer_timeout() -> void:
	can_aim = false
