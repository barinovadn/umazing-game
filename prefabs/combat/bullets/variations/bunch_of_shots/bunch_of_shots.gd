extends Bullet


@export var bullets: Array[PackedScene]
@export var amount: int = 5
@export var spacing: float
@export var offset: Vector2


func _bullet_ready():
	if not bullets:
		return
	
	var dir = direction
	var perp = Vector2(-dir.y, dir.x)
	var base_pos = global_position + dir * offset
	var half = (amount - 1) / 2.0
	
	for i in amount:
		var bullet = bullets.pick_random().instantiate() as Bullet
		var offset2 = (i - half) * spacing
		var spawn_pos = base_pos + perp * offset2
		
		bullet.global_position = spawn_pos
		bullet.team = team
		bullet.direction = dir
		
		Game.bullets.add_child(bullet)
		bullet.audio_player.volume_db = audio_player.volume_db
	
	destroy()
