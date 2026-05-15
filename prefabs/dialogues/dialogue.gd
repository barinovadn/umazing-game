class_name Dialogue
extends Resource


enum TypeSpeed { TURTLE, SLOW, NORMAL, FAST, RUSHED, INSTANT }

const TYPE_SPEED = {
	TypeSpeed.TURTLE: .3,
	TypeSpeed.SLOW: .08,
	TypeSpeed.NORMAL: .04,
	TypeSpeed.FAST: .025,
	TypeSpeed.RUSHED: .001,
	TypeSpeed.INSTANT: .0,
	}

@export var icon: Texture2D
@export var name: String
@export_multiline var message: String
@export var type_speed: TypeSpeed = TypeSpeed.NORMAL
@export var punctuation_significance: float = 1.0
@export var background: Color = Color(0.078, 0.106, 0.106)
@export var angle: float
@export var offset: Vector2
