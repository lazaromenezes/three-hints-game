extends Node

@export var settings: GameSettings

var session: GameSession

func _ready() -> void:
	if OS.has_feature("editor"):
		settings = load("res://resources/game_settings/debug_settings.tres")
	else:
		settings = load("res://resources/game_settings/default_settings.tres")

func new_session():
	session = GameSession.new()

func pick_words():
	return await WordProvider.get_words()

class GameSession:
	const TIME_TEMPLATE: String = "%02d:%02d.%03d"
	
	var total_points: int
	var total_time: float
	
	var formatted_time: String:
		get():
			var minutes: float = total_time / 60
			var seconds: float = fmod(total_time, 60)
			
			var milis: float = (total_time - floor(total_time)) * 1000
			
			return TIME_TEMPLATE % [minutes, seconds, milis]
	
	func _init():
		total_points = 0
		total_time = 0
