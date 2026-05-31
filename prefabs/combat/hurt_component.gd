@icon("hurt_component.png")
class_name HurtComponent
extends Area2D


signal fatal_damage_taken
signal damaged(by_amount: float)
signal healed(by_amount: float)
signal health_changed(by_amount: float)
signal max_health_changed

enum Team {
	NEUTRAL = 2,
	PLAYER = 1,
	ENEMY = 0,
	BREAKABLE = 3,
	}

@export var character: Character2D
@export var shape: Shape2D:
	set(value):
		shape = value
		_update_shape()
@export var is_one_shot: bool = true
@export var visible_hp_bar: bool = false

@export_group("Health")
@export var team: Team
@export var max_health: float = 1.0:
	set(value):
		var ratio: float = value / max_health
		max_health = value
		if current_health:
			current_health = (ratio * current_health)
		max_health_changed.emit()

@export_group("Sounds", "sounds")
@export var sounds_mute: bool = false
@export var sounds_player: AudioStreamPlayer2D
@export var sounds_damage: Array[AudioStream] = []
@export var sounds_die: Array[AudioStream] = []
@export var sounds_heal: Array[AudioStream] = []
@export var sounds_volume_db: float:
	set(value):
		sounds_volume_db = value
		if is_node_ready() and sounds_player != null:
			sounds_player.volume_db = value

@export_group("VFX", "vfx")
@export var vfx_mute: bool = false
@export var vfx_prettify_dmg_numbers: bool = true
@export var vfx_damage_marker: VFXProfile
@export var vfx_heal_marker: VFXProfile
@export_subgroup("Damage Marker Colors", "vfx_damage_marker_color")
@export var vfx_damage_marker_color_default: Color = Color.WHITE
@export var vfx_damage_marker_color_low_threshhold: float = 0.0
@export var vfx_damage_marker_color_low: Color = Color.YELLOW
@export var vfx_damage_marker_color_mid_threshhold: float = 0.5
@export var vfx_damage_marker_color_mid: Color = Color.ORANGE
@export var vfx_damage_marker_color_high_threshhold: float = 1.0
@export var vfx_damage_marker_color_high: Color = Color.RED

@onready var _collider: CollisionShape2D = %Collider
@onready var mob_hp: MobHP = $MobHP

var is_invulnerable: bool = false
var current_health: float:
	set(value):
		var flag: int
		if value < current_health:
			flag = 1
		elif value > current_health:
			flag = 2
		
		var _previous_health := current_health
		current_health = clamp(value, 0, max_health)
		health_changed.emit(value - _previous_health)
		
		if flag == 1:
			var dmg_amount: float = abs(_previous_health - current_health)
			damaged.emit(dmg_amount)
			_play_damage_marker_vfx(dmg_amount)
			_play_random_sound(sounds_damage)
		elif flag == 2:
			var heal_amount: float = abs(_previous_health - current_health)
			healed.emit(heal_amount)
			_play_heal_marker_vfx(heal_amount)
			_play_random_sound(sounds_heal)
			if not is_one_shot: _enable()
		
		if current_health <= 0:
			_disable()
			_play_random_sound(sounds_die)
			fatal_damage_taken.emit()
		_previous_health = current_health
var armor: float = 0.0


func _ready():
	current_health = max_health
	mob_hp.visible = visible_hp_bar
	if sounds_player:
		sounds_player.volume_db = sounds_volume_db
	if shape:
		_update_shape()


func _update_shape():
	if not is_inside_tree():
		return
	if not _collider:
		await get_tree().process_frame
	if not _collider:
		push_error("Could not load _collider in time")
		return
	
	_collider.disabled = not shape
	_collider.shape = shape


func _play_random_sound(array: Array[AudioStream]):
	if sounds_mute:
		return
	if array.size():
		sounds_player.stream = array.pick_random()
		sounds_player.play()


func _dmg_to_str(amount: float) -> String:
	if vfx_prettify_dmg_numbers:
		return str(int(amount * 100))
	
	return str(amount)


func _calc_damage_marker_color(dmg_amount: float) -> Color:
	if dmg_amount >= vfx_damage_marker_color_high_threshhold:
		return vfx_damage_marker_color_high
	if dmg_amount >= vfx_damage_marker_color_mid_threshhold:
		return vfx_damage_marker_color_mid
	if dmg_amount >= vfx_damage_marker_color_low_threshhold:
		return vfx_damage_marker_color_low
	return vfx_damage_marker_color_default


func _play_damage_marker_vfx(dmg_amount: float):
	if vfx_mute:
		return
	if not vfx_damage_marker:
		return
	
	vfx_damage_marker.settings.modulate = _calc_damage_marker_color(dmg_amount)
	vfx_damage_marker.settings.notification_text = '-' + _dmg_to_str(dmg_amount)
	vfx_damage_marker.spawn(global_position)


func _play_heal_marker_vfx(heal_amount: float):
	if vfx_mute:
		return
	if not vfx_heal_marker:
		return
	
	vfx_heal_marker.settings.notification_text = '+' + _dmg_to_str(heal_amount)
	vfx_heal_marker.spawn(global_position)


func _disable():
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)


func _enable():
	set_deferred("monitorable", true)
	set_deferred("monitoring", true)


func take_damage(amount: float = 0):
	if is_invulnerable:
		return
	if !armor:
		current_health -= amount
	else:
		var reduction_percent: float = clampf(armor / 100.0, 0.0, 1.0)
		var final_damage: float = amount * (1.0 - reduction_percent)

		current_health -= final_damage


func heal(amount: float = 0):
	healed.emit(amount)
	current_health += amount
