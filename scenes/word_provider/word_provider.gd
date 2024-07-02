extends Node

@onready var offline_word_provider: OfflineWordProvider = $OfflineWordProvider
@onready var online_word_provider: OnlineWordProvider = $OnlineWordProvider

var settings: GameSettings

func _ready() -> void:
	if OS.has_feature("editor"):
		settings = load("res://resources/game_settings/debug_settings.tres")
	else:
		settings = load("res://resources/game_settings/default_settings.tres")
		
	online_word_provider.settings = settings

func get_words():
	var amount := settings.words_per_match
	
	if settings.is_online:
		return await online_word_provider.take_random(amount)
	
	return offline_word_provider.take_random(amount)
