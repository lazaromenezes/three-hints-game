extends Node

signal player_finished()
signal room_created(id: String)
signal room_joined(name: String)

const SERVER_PEER: int = 1

@export var settings: GameSettings

var session: GameSession
var words: Array[Word]
var rooms: Dictionary
var current_room: String
var rank: Array[RankSummary] = []

func _ready() -> void:
	if OS.has_feature("editor"):
		settings = load("res://resources/game_settings/debug_settings.tres")
	else:
		settings = load("res://resources/game_settings/default_settings.tres")
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	#multiplayer.peer_connected.connect(_on_peer_connected)

func start_dedicated_server():
	rooms = {}
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(ServerManager.configuration.port, ServerManager.configuration.max_clients)
	multiplayer.multiplayer_peer = peer

func new_room(player_name: String):
	_join_host(player_name)
	
	await multiplayer.connected_to_server
	
	create_room.rpc_id(SERVER_PEER, player_name)

@rpc("any_peer", "reliable")
func create_room(player_name):
	var sender_id = multiplayer.get_remote_sender_id()
	var joining_session = GameSession.new(sender_id, player_name)
	
	var room = Room.new()
	room.add_session(joining_session)
	
	rooms[room.id] = room
	
	notify_room_created.rpc_id(sender_id, room.id, player_name)

@rpc("authority", "reliable")
func notify_room_created(room_id: String, player_name: String):
	current_room = room_id
	room_created.emit(room_id)
	room_joined.emit(player_name)

func join_room(room_id: String, player_name: String):
	_join_host(player_name)
	await multiplayer.connected_to_server
	enter_room.rpc_id(SERVER_PEER, room_id, player_name)
	current_room = room_id
	
@rpc("any_peer", "reliable")
func enter_room(room: String, player_name: String):
	var sender_id = multiplayer.get_remote_sender_id()
	var joining_session = GameSession.new(sender_id, player_name)
	
	rooms[room].add_session(joining_session)
	
	for player in rooms[room].sessions:
		notify_room_joined.rpc_id(player, player_name)
		
		if not player == sender_id:
			notify_room_joined.rpc_id(sender_id, rooms[room].sessions[player].player_name)

@rpc("authority", "reliable")
func notify_room_joined(player_name: String):
	room_joined.emit(player_name)

func _join_host(player_name: String):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ServerManager.configuration.host, ServerManager.configuration.port)
	
	if error != OK:
		print("Failed to join")
	else:
		multiplayer.multiplayer_peer = peer
		session = GameSession.new(multiplayer.get_unique_id(), player_name)

func request_start(words_package: PackedByteArray):
	start_room.rpc_id(SERVER_PEER, current_room, words_package)

@rpc("any_peer", "reliable")
func start_room(room_id: String, words_package: PackedByteArray):
	var room = rooms[room_id]
	
	for player in room.sessions:
		set_words.rpc_id(player, words_package)
		start_game.rpc_id(player)

@rpc("authority", "reliable")
func start_game():
	rank = []
	SceneManager.transition_to("multiplayer")

@rpc("authority", "reliable")
func set_words(words_package: PackedByteArray):
	words = bytes_to_var_with_objects(words_package)

func finish():
	update_points.rpc_id(SERVER_PEER, current_room, session.total_points, session.total_time)

@rpc("any_peer", "reliable")
func update_points(room_id, total_points, total_time):
	var sender_id = multiplayer.get_remote_sender_id()
	var room = rooms[room_id]
	var player_session = room.sessions[sender_id]
	
	room.define_score(sender_id, total_points, total_time)
	
	for player in room.sessions:
		notify_player_finished.rpc_id(player, player_session.player_name, total_points, total_time)

@rpc("authority", "reliable")
func notify_player_finished(player_name, total_points, total_time):
	rank.push_back(RankSummary.new(player_name, total_points, total_time))
	rank.sort_custom(RankSummary.sort_rank)
	
	player_finished.emit()

func _on_connected_to_server():
	print("CONNECTED")

func _on_connection_failed():
	print("CONNECTION_FAILED")

class GameSession:
	var total_points: int
	var total_time: float
	var player_name: String
	var peer_id: int
	var finished: bool = false
	
	func _init(id: int, name: String):
		total_points = 0
		total_time = 0
		player_name = name
		peer_id = id

class Room:
	var id: String
	var sessions: Dictionary = {}

	func _init():
		id = _new_id()
		
	func add_session(session: GameSession):
		sessions[session.peer_id] = session
	
	func define_score(player_id, total_points, total_time):
		sessions[player_id].total_points = total_points
		sessions[player_id].total_time = total_time
		sessions[player_id].finished = true
		
	func _new_id() -> String:
		var time = Time.get_unix_time_from_system()
		var random = randi()
		var input = "%s.%s" % [time, random]
		var diggest = input.md5_text()
		
		return diggest.substr(0, 5)

class RankSummary:
	const TIME_TEMPLATE: String = "%02d:%02d.%03d"
	
	var player: String
	var points: int
	var time: float
	
	var formatted_time: String:
		get():
			return _format_time()
	
	func _init(player_name: String, total_points: int, total_time: float):
		player = player_name
		points = total_points
		time = total_time

	func _format_time():
		var minutes: float = time / 60
		var seconds: float = fmod(time, 60)
		
		var milis: float = (time - floor(time)) * 1000
		
		return TIME_TEMPLATE % [minutes, seconds, milis]
		
	static func sort_rank(a: RankSummary, b: RankSummary):
		if a.points == b.points:
			return a.time < b.time
		else:
			return a.points > b.points
