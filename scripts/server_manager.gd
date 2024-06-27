extends Node

var configuration: Configuration

func _ready() -> void:
	configuration = Configuration.new()
	
	for argument in OS.get_cmdline_user_args():
		if argument.contains("--port"):
			configuration.port = int(argument.split("=")[1])
			
		if argument.contains("--server"):
			configuration.is_server = true
			
class Configuration:
	var port: int
	var is_server: bool
	var host: String
	var max_clients: int
	
	func _init():
		port = 1609
		is_server = false
		host = "127.0.0.1"
		max_clients = 2048
