class_name Dialogue
extends Resource


enum TypeSpeed { TURTLE, SLOW, NORMAL, FAST, RUSHED, INSTANT }

const TYPE_SPEEDS = {
	TypeSpeed.TURTLE: .3,
	TypeSpeed.SLOW: .08,
	TypeSpeed.NORMAL: .04,
	TypeSpeed.FAST: .025,
	TypeSpeed.RUSHED: .001,
	TypeSpeed.INSTANT: .0,
	}

@export var icon: Texture2D:
	get(): return icon if icon else (fallback.icon if fallback else icon)
@export var name: String:
	get(): return name if name else (fallback.name if fallback else name)
@export_multiline var message: String:
	get(): return message if message else (fallback.message if fallback else message)
@export var type_speed: TypeSpeed = TypeSpeed.NORMAL
@export var punctuation_significance: float = 1.0

## If any property of this [Dialogue] [Resource] is "falsy", will attempt to take
## that same property off the [member fallback] instead.
## [br][br][b]NOTE[/b]: This only works with properties that don't have default
## values like [member icon], [member name], [member message], [member angle] or
## [member offset].
@export var fallback: Dialogue

@export_group("Extra")
@export var background: Color = Color(0.078, 0.106, 0.106)
@export var font_color: Color = Color.WHITE
@export var angle: float:
	get(): return angle if angle else (fallback.angle if fallback else angle)
@export var offset: Vector2:
	get(): return offset if offset else (fallback.offset if fallback else offset)
