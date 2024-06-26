extends Node

signal player_connected()

@export var settings: GameSettings

var session: GameSession
var sessions: Dictionary

func _ready() -> void:
	if OS.has_feature("editor"):
		settings = load("res://resources/game_settings/debug_settings.tres")
	else:
		settings = load("res://resources/game_settings/default_settings.tres")
		
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.peer_connected.connect(_on_peer_connected)

func new_session(player_name: String):
	sessions = {}
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(8080)
	multiplayer.multiplayer_peer = peer
	
	session = GameSession.new(player_name)
	sessions[peer.get_unique_id()] = session
	player_connected.emit()

func join_session(host: String, player_name: String):
	sessions = {}
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(host, 8080)
	multiplayer.multiplayer_peer = peer
	
	session = GameSession.new(player_name)
	sessions[peer.get_unique_id()] = session

func _on_connected_to_server():
	print("CONNECTED")
	
func _on_connection_failed():
	print("CONNECTION_FAILED")
	
func _on_peer_connected(id: int):
	register_peer.rpc_id(id, session.player_name)

@rpc("any_peer", "reliable")
func register_peer(player_name):
	var upcoming_id = multiplayer.get_remote_sender_id()
	sessions[upcoming_id] = GameSession.new(player_name)
	player_connected.emit()

class GameSession:
	const TIME_TEMPLATE: String = "%02d:%02d.%03d"
	
	var total_points: int
	var total_time: float
	var player_name: String
	
	var formatted_time: String:
		get():
			var minutes: float = total_time / 60
			var seconds: float = fmod(total_time, 60)
			
			var milis: float = (total_time - floor(total_time)) * 1000
			
			return TIME_TEMPLATE % [minutes, seconds, milis]
	
	func _init(name: String):
		total_points = 0
		total_time = 0
		player_name = name
		
