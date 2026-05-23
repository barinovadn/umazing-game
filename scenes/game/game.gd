extends Node2D


func _ready():
	Game.player = %Player
	
	Game.music_player = %MusicPlayer
	Game.dialogue_system = %DialogueSystem
	Game.vfx_manager = %VFXManager
	Game.env_particles = Game.player.env_particles
	Game.env_filter = Game.player.env_filter
	
	Game.bullets = %Bullets
	Game.enemies = %Enemies
	Game.pickups = %Pickups
	Game.timers = %Timers
