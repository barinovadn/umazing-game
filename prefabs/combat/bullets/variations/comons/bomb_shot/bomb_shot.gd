extends Bullet

@export var explosion_koefitient: float = 1.0

var _was_exploded: bool = false

func _on_area_entered(area: Area2D):
	if not _can_damage_team(area.team):
		return
	if not _was_exploded and area.name != "DamageArea":
		collision_shape_2d.scale *= explosion_koefitient
		_was_exploded = true
	if area is HurtComponent:
		_crashed_into_hurt_component(area)
		area.take_damage(_calc_damage(area))
		get_tree().create_timer(0.05).timeout.connect(destroy)
		return
	if area is Bullet:
		if can_be_broken and area.can_break:
			get_tree().create_timer(0.05).timeout.connect(destroy)
		return

func _on_map_collision(_body: Node2D):
	if not _was_exploded:
		collision_shape_2d.scale *= explosion_koefitient
		_was_exploded = true
	
	get_tree().create_timer(0.05).timeout.connect(destroy)
