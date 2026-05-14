extends Bullet

@export var use_bullet_autoaim: bool = false
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
	
	target = get_nearest_target()
	
	for i in amount:
		var bullet = bullets.pick_random().instantiate() as Bullet
		var offset2 = (i - half) * spacing
		var spawn_pos = base_pos + perp * offset2
		
		if use_bullet_autoaim:
			bullet.homing = homing
		else:
			bullet.homing = false
		
		bullet.can_break = can_break
		bullet.can_be_broken = can_be_broken
		bullet.direction = _get_direction_to_target()
		bullet.global_position = spawn_pos
		bullet.team = team
		bullet.bounces = bounces
		
		Game.bullets.add_child(bullet)
		bullet.audio_player.volume_db = audio_player.volume_db
	
	destroy()
