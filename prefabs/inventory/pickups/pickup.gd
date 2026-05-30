@icon("pickup.png")
class_name Pickup
extends RigidBody2D


@export var item_data: ItemData
@export var default_sound_pickup: AudioStream

@export var default_vfx_spawn: VFXProfile
@export var default_vfx_collect: VFXProfile

@export_group("Afterlife", "afterlife")
@export var afterlife_duration: float = 7.0

#@onready var inventory = Game.inventory
@onready var sprite = $Icon
@onready var light = $Icon/RarityLight
@onready var audio_player = $SoundPlayer 

var is_deleted: bool = false:
	set(value):
		if not value or value == is_deleted:
			return
		is_deleted = value
		visible = false
		$Collider.set_deferred("disabled", true)
		await get_tree().create_timer(afterlife_duration).timeout
		queue_free()


func _ready():
	if item_data:
		sprite.texture = item_data.icon
		set_light_by_rarity(item_data)

	var vfx_spawn = item_data.rarity_spawn_vfx.get(item_data.rarity)
	if not vfx_spawn:
		vfx_spawn = default_vfx_spawn
		
	if vfx_spawn:
		vfx_spawn.spawn.call_deferred(global_position)


func set_light_by_rarity(data: ItemData):
	if light and data: 
		light.color = data.rarity_colors.get(data.rarity, Color.WHITE)


func collect(inventory: Inventory):
	if not inventory:
		return

	var leftover = inventory.add_item(item_data)
	if leftover > 0:
		item_data.amount = leftover
		return

	if item_data:
		_play_pickup_sfx()
		_spawn_pickup_vfx()
	
	delete()


func _play_pickup_sfx():
	if not audio_player: return
	var target_sound = item_data.rarity_sounds.get(item_data.rarity, default_sound_pickup)
	if target_sound:
		audio_player.stream = target_sound
		audio_player.play()


func _spawn_pickup_vfx():
	var vfx_collect = item_data.rarity_collect_vfx.get(item_data.rarity, default_vfx_collect)
	if vfx_collect:
		vfx_collect.spawn(global_position)


func delete():
	is_deleted = true
