@icon("animation_controller.png")
class_name AnimationController2D
extends Node
## Controls the animations for [AnimatedSprite2D].

var is_shooting: bool  = false

## Available animation types.
enum AnimationType {
	NONE = 0, # WARNING Keep falsy
	
	## NOTE: Use [method play_down] for auto-direction.
	IDLE_DOWN,
	IDLE_UP,
	IDLE_LEFT,
	IDLE_RIGHT,
	
	## NOTE: Use [method play_idle] for auto-direction.
	WALK_DOWN,
	WALK_UP,
	WALK_LEFT,
	WALK_RIGHT,
	
	## NOTE: Use [method play_attack] for auto-direction.
	ATTACK_DOWN,
	ATTACK_UP,
	ATTACK_LEFT,
	ATTACK_RIGHT,
	
	DOWNED, ## Downed, KO, asleep or drooping.
	STANCE, ## Battle stance.
	CROUCH, ## Crouch, spell cast.
	PRAISE, ## Hands above the head.
	BOWING, ## Praise & downed loop.
	PATROL, ## Looking around.
	TRAINS, ## Battle training.
	}

## The [AnimatedSprite2D] node this controller operates on.
@export var animated_sprite: AnimatedSprite2D
## Maps [enum AnimationType]s to actual animation names in the [AnimatedSprite2D].
@export var animations: Dictionary[AnimationType, String] = {
	AnimationType.IDLE_DOWN: 'idle_down',
	AnimationType.IDLE_UP: 'idle_up',
	AnimationType.IDLE_LEFT: 'idle_left',
	AnimationType.IDLE_RIGHT: 'idle_right',
	
	AnimationType.WALK_DOWN: 'walk_down',
	AnimationType.WALK_UP: 'walk_up',
	AnimationType.WALK_LEFT: 'walk_left',
	AnimationType.WALK_RIGHT: 'walk_right',
	
	AnimationType.ATTACK_DOWN: 'attack_down',
	AnimationType.ATTACK_UP: 'attack_up',
	AnimationType.ATTACK_LEFT: 'attack_left',
	AnimationType.ATTACK_RIGHT: 'attack_right',
	
	AnimationType.DOWNED: 'downed',
	AnimationType.STANCE: 'stance',
	AnimationType.CROUCH: 'crouch',
	AnimationType.PRAISE: 'praise',
	AnimationType.BOWING: 'bowing',
	AnimationType.PATROL: 'patrol',
	AnimationType.TRAINS: 'trains',
	}
## Horizontal flip that will be applied to each specified [enum AnimationType].
@export var animations_flip_h: Dictionary[AnimationType, bool] = {
	AnimationType.IDLE_DOWN: false,
	AnimationType.IDLE_UP: false,
	AnimationType.IDLE_LEFT: false,
	AnimationType.IDLE_RIGHT: false,
	
	AnimationType.WALK_DOWN: false,
	AnimationType.WALK_UP: false,
	AnimationType.WALK_LEFT: false,
	AnimationType.WALK_RIGHT: false,
	
	AnimationType.ATTACK_DOWN: false,
	AnimationType.ATTACK_UP: false,
	AnimationType.ATTACK_LEFT: false,
	AnimationType.ATTACK_RIGHT: false,
	
	AnimationType.DOWNED: false,
	AnimationType.STANCE: false,
	AnimationType.CROUCH: false,
	AnimationType.PRAISE: false,
	AnimationType.BOWING: false,
	AnimationType.PATROL: false,
	AnimationType.TRAINS: false,
	}
## Vertical flip that will be applied to each specified [enum AnimationType].
@export var animations_flip_v: Dictionary[AnimationType, bool] = {
	AnimationType.IDLE_DOWN: false,
	AnimationType.IDLE_UP: false,
	AnimationType.IDLE_LEFT: false,
	AnimationType.IDLE_RIGHT: false,
	
	AnimationType.WALK_DOWN: false,
	AnimationType.WALK_UP: false,
	AnimationType.WALK_LEFT: false,
	AnimationType.WALK_RIGHT: false,
	
	AnimationType.ATTACK_DOWN: false,
	AnimationType.ATTACK_UP: false,
	AnimationType.ATTACK_LEFT: false,
	AnimationType.ATTACK_RIGHT: false,
	
	AnimationType.DOWNED: false,
	AnimationType.STANCE: false,
	AnimationType.CROUCH: false,
	AnimationType.PRAISE: false,
	AnimationType.BOWING: false,
	AnimationType.PATROL: false,
	AnimationType.TRAINS: false,
	}


func _ready():
	if not animated_sprite:
		animated_sprite = get_parent() as AnimatedSprite2D
	
	if not animated_sprite:
		push_error("\"character_body\" was not assigned and parent is not "
			+ "AnimatedSprite2D. Disabling controller.")


## Checks if the given [enum AnimationType] is valid and the animation exists in
## [member animated_sprite.sprite_frames].
## [member AnimationType.NONE] will always return [code]false[/code].
func has_animation(animation: AnimationType) -> bool:
	# Type none
	if animation == AnimationType.NONE:
		return false
	# Unknown type
	if not animation in animations:
		return false
	# No animated sprite
	if not animated_sprite:
		return false
	# No animation
	if not animated_sprite.sprite_frames.has_animation(animations[animation]):
		return false
	
	return true


## Plays the specified [param animation] if it exists in [member animations].
## Will ignore the call if given [member AnimationType.NONE].
func play(animation: AnimationType):
	if not has_animation(animation):
		if animation:
			push_warning("No animation with type #", animation, " found.")
		return
	
	if animations_flip_h.has(animation):
		animated_sprite.flip_h = animations_flip_h[animation]
	if animations_flip_v.has(animation):
		animated_sprite.flip_v = animations_flip_v[animation]
	
	animated_sprite.play(animations[animation])
	if is_shooting:
		await get_tree().create_timer(0.3).timeout
		is_shooting = false

## Plays an idle animation based on [param direction].
func play_idle(direction: Vector2 = Vector2.ZERO):
	
	if is_shooting:
		return
		
	if direction.x < -0.5: 
		play(AnimationType.IDLE_LEFT)
		return
	if direction.x > 0.5: 
		play(AnimationType.IDLE_RIGHT)
		return
	if direction.y < -0.5: 
		play(AnimationType.IDLE_UP)
		return
	if direction.y > 0.5: 
		play(AnimationType.IDLE_DOWN)
		return
	play(AnimationType.IDLE_DOWN)


## Plays a walk animation based on [param direction].
func play_walk(direction: Vector2 = Vector2.ZERO):
	if is_shooting:
		return
		
	if direction.x < -0.5: 
		play(AnimationType.WALK_LEFT)
		return
	if direction.x > 0.5: 
		play(AnimationType.WALK_RIGHT)
		return
	if direction.y < -0.5: 
		play(AnimationType.WALK_UP)
		return
	if direction.y > 0.5: 
		play(AnimationType.WALK_DOWN)
		return
	play(AnimationType.WALK_DOWN)


## Plays an attack animation based on [param direction].
func play_attack(direction: Vector2 = Vector2.ZERO):
	is_shooting = true
	if direction.x < 0: 
		play(AnimationType.ATTACK_LEFT)
		return
	if direction.x > 0: 
		play(AnimationType.ATTACK_RIGHT)
		return
	if direction.y < 0: 
		play(AnimationType.ATTACK_UP)
		return
	if direction.y > 0: 
		play(AnimationType.ATTACK_DOWN)
		return
	play(AnimationType.ATTACK_DOWN)

func play_death():
	animated_sprite.play(animations[AnimationType.DOWNED])
