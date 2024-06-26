extends Control

func _ready() -> void:
	MultiplayerGameManager.player_connected.connect(_on_player_connected)

func _on_host_game_pressed() -> void:
	var player_name = %PlayerName.text
	
	MultiplayerGameManager.new_session(player_name)

func _on_join_pressed() -> void:
	var player_name = %PlayerName.text
	var host = %HostAddress.text
	
	MultiplayerGameManager.join_session(host, player_name)

func _on_player_connected() -> void:
	%ConnectedPlayers.get_children().all(func (c): c.queue_free())
	
	_update_player_list.call_deferred()
	
func _update_player_list():
	for player in MultiplayerGameManager.sessions:
		var player_label = Label.new()
		player_label.text = MultiplayerGameManager.sessions[player].player_name
		%ConnectedPlayers.add_child(player_label)
