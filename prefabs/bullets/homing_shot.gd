extends HitComponent
class_name HomingProjectile

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var direction = Vector2.RIGHT
var speed: float = 80.0  # значение по умолчанию, будет переопределено
var homing_time: float = 2.0
var current_homing_time = 0.0
var target = null

func _ready() -> void:
	animated_sprite_2d.play("homing_shot")
	# Получаем скорость из контроллера (если он есть в группе)
	var controller = get_tree().get_first_node_in_group("fight_controller")
	if controller:
		speed = controller.bullet_speed

func _process(delta: float) -> void:
	
	current_homing_time += delta
	
	if current_homing_time >= homing_time:
		position += speed * Vector2.RIGHT.rotated(rotation) * delta
		
	elif target:
		look_at(target.global_position)
		position = position.move_toward(target.global_position, speed * delta)
	
	#position += direction * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func set_target(settable):
	target = settable

func _on_area_entered(area: Area2D) -> void:
	visible = false
