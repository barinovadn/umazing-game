extends Bullet

@export var use_bullet_autoaim: bool = false
@export var bullets: Array[PackedScene]
@export var amount: int = 8
@export var radius: float = 0.0 
@export var offset: Vector2

func _bullet_ready():
	if bullets.is_empty():
		return
	
	var angle_step = 2.0 * PI / amount
	var base_pos = global_position + offset
	
	for i in amount:
		var bullet_res = bullets.pick_random()
		if not bullet_res: continue
		
		var bullet = bullet_res.instantiate() as Bullet
		
		var spawn_direction = Vector2.RIGHT.rotated(i * angle_step)
		
		bullet.team = team
		bullet.direction = spawn_direction
		bullet.global_position = base_pos + spawn_direction * radius
		
		bullet.can_break = can_break
		bullet.can_be_broken = can_be_broken
		bullet.bounces = bounces
		
		if use_bullet_autoaim:
			bullet.homing = homing
		else:
			bullet.homing = false
			
		Game.bullets.add_child(bullet)
		
		bullet.audio_player.volume_db = audio_player.volume_db
	
	destroy()
