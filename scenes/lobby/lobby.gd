extends Control

@onready var offline_word_provider: OfflineWordProvider = $OfflineWordProvider

func _ready() -> void:
	MultiplayerGameManager.player_connected.connect(_on_player_connected)

func _on_host_game_pressed() -> void:
	var player_name = %PlayerName.text
	MultiplayerGameManager.new_session(player_name)
	%Play.visible = true

func _on_join_pressed() -> void:
	var player_name = %PlayerName.text
	var host = %HostAddress.text if not %HostAddress.text.is_empty() else "127.0.0.1"
	
	MultiplayerGameManager.join_session(host, player_name)

func _on_player_connected() -> void:
	%ConnectedPlayers.get_children().all(func (c): c.queue_free())
	
	_update_player_list.call_deferred()

func _update_player_list():
	for player in MultiplayerGameManager.sessions:
		var player_label = Label.new()
		player_label.text = MultiplayerGameManager.sessions[player].player_name
		%ConnectedPlayers.add_child(player_label)

func _on_play_pressed() -> void:
	var words: Array[Word] = offline_word_provider.take_random(5)
	var words_package: PackedByteArray = var_to_bytes_with_objects(words)
	MultiplayerGameManager.set_words.rpc(words_package)
	MultiplayerGameManager.start_game.rpc()
