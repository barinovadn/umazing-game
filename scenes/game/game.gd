extends Node2D


func _ready():
	Game.player = %Player
	Game.music_player = %MusicPlayer
	Game.vfx_manager = %VFXManager
	
	Game.bullets = %Bullets
	Game.enemies = %Enemies
