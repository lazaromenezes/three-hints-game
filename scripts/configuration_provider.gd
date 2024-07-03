extends Node

var settings: GameSettings
var server: ServerConfiguration
var is_server: bool = false

func _ready() -> void:
	if OS.has_feature("editor"):
		settings = load("res://resources/game_settings/debug_settings.tres")
	else:
		settings = load("res://resources/game_settings/default_settings.tres")

	server = ServerConfiguration.new(settings)
	
	for argument in OS.get_cmdline_user_args():
		if argument.contains("--port"):
			server.port = int(argument.split("=")[1])
			
		if argument.contains("--server"):
			is_server = true

class ServerConfiguration:
	var port: int
	var host: String
	var max_clients: int
	
	func _init(settings: GameSettings):
		port = settings.server_port
		host = settings.server_url
		max_clients = settings.max_clients
