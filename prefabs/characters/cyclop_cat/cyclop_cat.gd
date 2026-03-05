extends Character2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

signal cat_damaged(current_health: int)
signal cat_died

#var sounds = [
	#preload("uid://cj158onm83oe4"),
	#preload("uid://bu3iow2nf7xc1"),
	#preload("uid://btaqr0ytvm3m4"),
	#preload("uid://b78ji5i7pwh7k"),
	#preload("uid://cno6cwfsychmf")
#]

enum Actions{
	STRAIGHT_SHOT,
	SINUSOID_SHOT,
	HOMING_SHOT,
	SPRAY_SHOT
}

@onready var health_system: HealthSystem = $HealthSystem
const STONE_SHOT = preload("uid://1fs5fg40bjar")
const HOMING_SHOT = preload("uid://ccbamilt8pd75")
@onready var pause_between_shots: Timer = $PauseBetweenShots
@onready var action_changer: Timer = $ActionChanger

var movement_points
var current_movement_point
var spray_shot_count = 3
var current_action
var min_projectile_degree = -15

func init():
	var random_point = movement_points.pick_random()
	current_movement_point = random_point.position
	health_system.damaged.connect(on_damaged)
	health_system.died.connect(on_died)
	pause_between_shots.setup()
	action_changer.setup()
	#audio_stream_player.finished.connect(on_sound_finished)

#func on_sound_finished():
	#if !get_health():
		#queue_free()
#
func on_died():
	cat_died.emit()

func on_damaged():
	#if get_health() < 0:
		#audio_stream_player.stream = sounds.pick_random()
		#audio_stream_player.play()
		#vlad_died.emit()
	cat_damaged.emit(get_health())
	
	#if health_system.health == 10:
		#trigger_second_phase()
	#audio_stream_player.stream = sounds.pick_random()
	#audio_stream_player.play()

#func trigger_second_phase():
	#phase = Phase.TWO
	#action_timer.min_time = 1
	#action_timer.max_time = 2
	#spray_shot_count = 5
	#min_projectile_degree = -30
	#bat_speed = 425
	#bat_homing_time = 1.5

func _process(delta: float) -> void:
	global_position = global_position.move_toward(current_movement_point, delta * SPEED)
	
	if global_position.distance_squared_to(current_movement_point) < 0.1:
		current_movement_point = movement_points.pick_random().global_position


func get_health():
	return health_system.health

func _on_area_entered(area: Area2D) -> void:
	health_system.damage(1)


func pick_action():
	var rand_point: int = randi_range(0, 3) as Actions
	return rand_point


func _on_pause_between_shots_timeout() -> void:
	match current_action:
		
		Actions.STRAIGHT_SHOT:
			var devil = ENEMY.instantiate()
			get_tree().root.add_child(devil)
			devil.init(DEVIL_ENEMY_CONFIG, movement_points)
			devil.global_position = movement_points.pick_random().global_position
		Actions.HOMING_SHOT:
			animated_sprite_2d.play("shooting")
			var homing_bat = HOMING_BAT.instantiate()
			homing_bat.speed = bat_speed
			homing_bat.max_homing_time = bat_homing_time
			homing_bat.global_position = shooting_point.global_position
			get_tree().root.add_child(homing_bat)
		Actions.SPRAY_SHOT:
			animated_sprite_2d.play("shooting")
			for i in spray_shot_count:
				var projectile = ENEMY_PROJECTILE.instantiate() as EnemyProjectile
				projectile.global_position = shooting_point.global_position
				get_tree().root.add_child(projectile)
				projectile.rotation_degrees = min_projectile_degree + 15 * i
				projectile.set_vlad_pattern()
				projectile.set_projectile_texture(RING)
		Actions.SINUSOID_SHOT:
			animated_sprite_2d.play("shooting")
			for i in spray_shot_count:
				var projectile = ENEMY_PROJECTILE.instantiate() as EnemyProjectile
				projectile.global_position = shooting_point.global_position
				get_tree().root.add_child(projectile)
				projectile.rotation_degrees = min_projectile_degree + 15 * i
				projectile.set_vlad_pattern()
				projectile.set_projectile_texture(RING)


func _on_action_changer_timeout() -> void:
	current_action = pick_action()
