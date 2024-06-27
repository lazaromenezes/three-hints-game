extends Node

signal player_connected()
signal player_finished()
signal room_created(id: String)

const SERVER_PEER: int = 1

@export var settings: GameSettings

var session: GameSession
var words: Array[Word]
var rooms: Dictionary

func _ready() -> void:
	if OS.has_feature("editor"):
		settings = load("res://resources/game_settings/debug_settings.tres")
	else:
		settings = load("res://resources/game_settings/default_settings.tres")
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.peer_connected.connect(_on_peer_connected)
	
func start_dedicated_server():
	rooms = {}
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(ServerManager.configuration.port, ServerManager.configuration.max_clients)
	multiplayer.multiplayer_peer = peer
	
	print(peer.get_unique_id())

func new_room(player_name: String):
	_join_host(player_name)
	
	await multiplayer.connected_to_server
	
	create_room.rpc_id(SERVER_PEER, player_name)

@rpc("authority")
func notify_room_created(id: String):
	room_created.emit(id)

@rpc("any_peer")
func create_room(player_name):
	var sender_id = multiplayer.get_remote_sender_id()
	var room = Room.new()
	var session = GameSession.new(player_name)
	
	room.add_session(sender_id, session)
	
	notify_room_created.rpc_id(sender_id, room.id)

func join_room(host: String, player_name: String):
	_join_host(player_name)
	#var peer = ENetMultiplayerPeer.new()
	#peer.create_client(ServerManager.configuration.host, ServerManager.configuration.port)
	#multiplayer.multiplayer_peer = peer
	#
	#session = GameSession.new(player_name)
	#sessions[peer.get_unique_id()] = session

func _join_host(player_name: String):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ServerManager.configuration.host, ServerManager.configuration.port)
	
	if error != OK:
		print("Failed to join")
	else:
		multiplayer.multiplayer_peer = peer
		session = GameSession.new(player_name)
		print(peer.get_unique_id())
	
func _on_connected_to_server():
	player_connected.emit()

func _on_connection_failed():
	print("CONNECTION_FAILED")

func _on_peer_connected(id: int):
	if not multiplayer.is_server():
		register_peer.rpc_id(id, session.player_name)

@rpc("any_peer", "reliable")
func register_peer(player_name):
	var sender_id = multiplayer.get_remote_sender_id()
	#sessions[sender_id] = GameSession.new(player_name)
	player_connected.emit()

@rpc("call_local", "reliable")
func start_game():
	SceneManager.transition_to("multiplayer")

@rpc("call_local", "any_peer", "reliable")
func set_words(words_package: PackedByteArray):
	words = bytes_to_var_with_objects(words_package)

func finish():
	update_points.rpc(session.total_points, session.total_time)

@rpc("call_local", "any_peer", "reliable")
func update_points(total_points, total_time):
	#sessions[multiplayer.get_remote_sender_id()].total_points = total_points
	#sessions[multiplayer.get_remote_sender_id()].total_time = total_time
	#sessions[multiplayer.get_remote_sender_id()].finished = true
	
	player_finished.emit()

func rank_finished_players():
	var finished: Array[GameSession] = []
	
	#for id in sessions:
		#var local_session: GameSession = sessions[id]
		#if local_session.finished:
			#finished.push_back(local_session)
			
	finished.sort_custom(_rank_sessions)
	
	return finished

func _rank_sessions(a: GameSession, b: GameSession):
	if a.total_points == b.total_points:
		return a.total_time < b.total_time
	else:
		return a.total_points > b.total_points

class GameSession:
	const TIME_TEMPLATE: String = "%02d:%02d.%03d"
	
	var total_points: int
	var total_time: float
	var player_name: String
	var finished: bool = false
	
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

class Room:
	var id: String
	var sessions: Dictionary = {}

	func _init():
		id = _new_id()
		
	func add_session(id, session: GameSession):
		sessions[id] = session
		
	func _new_id() -> String:
		var time = Time.get_unix_time_from_system()
		var random = randi()
		
		var input = "%s.%s" % [time, random]
		
		var diggest = input.md5_text()
		
		return diggest.substr(0, 5)
