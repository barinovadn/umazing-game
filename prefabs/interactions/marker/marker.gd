@tool
@icon("marker.png")
class_name InteractionMarker
extends Node2D


enum MarkerSprite {
	NONE,
	QUESTION_MARK,
	EYE,
	CHEST,
	KEY,
	X,
	}
enum MarkerAnimation {
	NONE,
	FLOAT,
	}
enum MarkerAnimationSpeed {
	ZERO = -2,
	SLOW = -1,
	NORMAL = 0,
	FAST = 1,
	}
enum MarkerColor {
	WHITE,
	YELLOW,
	ORANGE,
	RED,
	GREEN,
	BLUE,
	}

const MARKER_SPRITES: Dictionary[MarkerSprite, String] = {
	MarkerSprite.NONE: "none",
	MarkerSprite.QUESTION_MARK: "question_mark",
	MarkerSprite.EYE: "eye",
	MarkerSprite.CHEST: "chest",
	MarkerSprite.KEY: "key",
	MarkerSprite.X: "x",
	}
const MARKER_ANIMATIONS: Dictionary[MarkerAnimation, String] = {
	MarkerAnimation.NONE: "RESET",
	MarkerAnimation.FLOAT: "FLOAT",
	}
const MARKER_ANIMATION_SPEEDS: Dictionary[MarkerAnimationSpeed, float] = {
	MarkerAnimationSpeed.ZERO: 0,
	MarkerAnimationSpeed.SLOW: 0.5,
	MarkerAnimationSpeed.NORMAL: 1.0,
	MarkerAnimationSpeed.FAST: 1.5,
	}
const MARKER_COLORS: Dictionary[MarkerColor, Color] = {
	MarkerColor.WHITE: Color.WHITE,
	MarkerColor.YELLOW: Color(1.0, 1.0, 0.5),
	MarkerColor.ORANGE: Color(1.0, 0.5, 0.0),
	MarkerColor.RED: Color(1.0, 0.25, 0.25),
	MarkerColor.GREEN: Color(0.0, 1.0, 0.5),
	MarkerColor.BLUE: Color(0.5, 0.5, 1.0),
	}

@export var sprite: MarkerSprite:
	set(value):
		sprite = value
		_apply_settings.call_deferred()
@export var color: MarkerColor:
	set(value):
		color = value
		_apply_settings.call_deferred()
@export var animation: MarkerAnimation:
	set(value):
		animation = value
		_apply_settings.call_deferred()
@export var animation_speed: MarkerAnimationSpeed:
	set(value):
		animation_speed = value
		_apply_settings.call_deferred()

@export_group("Custom Overwrites", "custom")
@export var custom_color: Color:
	set(value):
		custom_color = value
		_apply_settings.call_deferred()
@export var custom_animation_speed: float:
	set(value):
		custom_animation_speed = value
		_apply_settings.call_deferred()

@onready var animated_sprite: AnimatedSprite2D = %Sprite
@onready var animation_player: AnimationPlayer = %AnimationPlayer


func _ready():
	_apply_settings()


func _apply_settings():
	if not animated_sprite or not animation_player:
		return
	
	animated_sprite.animation = MARKER_SPRITES[sprite]
	modulate = custom_color if custom_color else MARKER_COLORS[color]
	animation_player.play(MARKER_ANIMATIONS[animation])
	animation_player.speed_scale = (
		custom_animation_speed if custom_animation_speed
		else MARKER_ANIMATION_SPEEDS[animation_speed] )
