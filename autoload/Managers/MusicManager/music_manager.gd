extends Node2D

## Скрипт в который загружается вся музыка и звуковые эффекты

## Перечисление музыкальных треков
enum Compositions {
	CatBossFightMusic,
	CalmLevelSunnyMusic
}

## Пеерчисление звуковых эффектов
enum Sound_Effects{
	Succes,
	GameOver
}

## Массив с музыкой
@onready var Music_array: Array = [
	preload("uid://c7ff00rpcbk0k"),
	preload("uid://b84rp3gyrlcd6")
]

## Массив со звуками
@onready var Sound_effects_array: Array = [
	preload("uid://dv1j4vpqs6wiy"), 
	preload("uid://ctp44o4x0ppv")
]

## Возвращает предзагруженный трек
func give_composition(song : Compositions):
	return Music_array[song]

## Возвращает предзагруженный звуковой эффект
func give_sound_effect(sf : Sound_Effects):
	return Sound_effects_array[sf]
