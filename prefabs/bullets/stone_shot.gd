extends HitComponent
class_name StoneProjectile


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var direction = Vector2.RIGHT
var speed: float = 120.0  # значение по умолчанию, будет переопределено

func _ready() -> void:
	animated_sprite_2d.play("stone_shot")
	# Получаем скорость из контроллера (если он есть в группе)
	var controller = get_tree().get_first_node_in_group("fight_controller")
	if controller:
		speed = controller.bullet_speed

func _process(delta: float) -> void:
	position += direction * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	queue_free()
	
func _on_body_entered(body: Node2D) -> void:
	visible = false
