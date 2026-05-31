extends Bullet

@export var bullet_types: Array[PackedScene]

@export var amount: int = 5
@export var spacing: float
@export var offset: Vector2

func _bullet_ready():
	if not bullet_types:
		return
	
	var dir = Vector2.DOWN
	var perp = Vector2.RIGHT
	var base_pos = global_position + dir * offset
	
	for i in amount:
		var bullet = bullet_types.pick_random().instantiate() as Bullet
		var offset2 = i * spacing
		var spawn_pos = base_pos + perp * offset2
		
		bullet.homing = false
		
		bullet.can_break = can_break
		bullet.can_be_broken = can_be_broken
		bullet.direction = dir
		bullet.global_position = spawn_pos
		bullet.team = team
		bullet.bounces = bounces
		
		Game.bullets.add_child(bullet)
		bullet.audio_player.volume_db = audio_player.volume_db
	
	destroy()
