extends Node2D

@onready var teleport_cat_exit: TeleportCatExit = $Teleports/TeleportCatExit
@onready var teleport_cat_intro: TeleportCat = $Teleports/TeleportCatIntro
@onready var music_player: AudioStreamPlayer2D = $Music/MusicPlayer

@export var teleport_back_intro : Teleport

@export var ninja_green : Character2D
@export var enemy_controller: EnemyMovementController2D
@export var pig_follow: BehaviourFollow2D
@export var ninja_blue_follow: BehaviourFollow2D
@export var player_controller: PlayerMovementController2D 
@export var player_ui : UI
@export var cyclop_cat : Character2D

var currenc_trek

func _ready() -> void:
	teleport_cat_exit.fight_ended.connect(on_fight_ended)
	teleport_cat_intro.fight_started.connect(on_fight_started)
	cyclop_cat.died.connect(on_cyclop_cat_died)
	ninja_green.died.connect(on_ninja_green_died)
	currenc_trek = music_player.stream

func on_fight_ended():
	music_player.volume_db = 0
	ninja_green.fight_enabled = false
	player_controller.movement_speed = 60.0
	player_ui.visible = false
	pig_follow.movement_enabled = true
	ninja_blue_follow.movement_enabled = true
	teleport_cat_intro.set_deferred("monitorable", false)
	teleport_cat_intro.monitoring = false
	currenc_trek = music_player.stream

func on_fight_started():
	music_player.volume_db = 6
	music_player.stream = MusicManager.give_composition(MusicManager.Compositions.CatBossFightMusic)
	music_player.play()
	ninja_green.fight_enabled = true
	cyclop_cat.fight_enabled = true
	cyclop_cat.movement.movement_enabled = true
	player_controller.movement_speed = 30
	player_ui.visible = true
	pig_follow.movement_enabled = false
	ninja_blue_follow.movement_enabled = false
	currenc_trek = music_player.stream

func on_ninja_green_died():
	music_player.stream = MusicManager.give_sound_effect(MusicManager.Sound_Effects.GameOver)
	music_player.play()
	currenc_trek = music_player.stream
	
func on_cyclop_cat_died():
	music_player.stream = MusicManager.give_sound_effect(MusicManager.Sound_Effects.Succes)
	music_player.play()
	await music_player.finished
	music_player.stream = MusicManager.give_composition(MusicManager.Compositions.CalmLevelSunnyMusic)
	music_player.play()
	currenc_trek = music_player.stream


func _on_music_player_finished() -> void:
	music_player.stream = currenc_trek
	music_player.play()
