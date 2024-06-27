extends Control

@onready var offline_word_provider: OfflineWordProvider = $OfflineWordProvider

func _ready() -> void:
	MultiplayerGameManager.room_joined.connect(_on_player_connected)
	MultiplayerGameManager.room_created.connect(_on_room_created)

func _on_room_created(id: String) -> void:
	%Room.text = id

func _on_host_game_pressed() -> void:
	var player_name = %PlayerName.text
	MultiplayerGameManager.new_room(player_name)
	%Play.visible = true

func _on_join_pressed() -> void:
	var player_name = %PlayerName.text
	
	MultiplayerGameManager.join_room(%RoomId.text, player_name)

func _on_player_connected(player_name: String) -> void:
	var player_label = Label.new()
	player_label.text = player_name
	%ConnectedPlayers.add_child(player_label)

func _on_play_pressed() -> void:
	var words: Array[Word] = offline_word_provider.take_random(5)
	var words_package: PackedByteArray = var_to_bytes_with_objects(words)
	
	MultiplayerGameManager.request_start(words_package)
