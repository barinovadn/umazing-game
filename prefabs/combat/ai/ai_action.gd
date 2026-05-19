extends Resource
class_name AIAction

@export var action_name: String
@export var weight: float
@export var phases: Array[int]
@export var duration: float
@export var can_shoot: bool
@export var can_move: bool
@export var bullet_types: Array[PackedScene]
@export var shoot_interval: float
@export var shooting_animation_interval: float
