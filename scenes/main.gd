extends Node

func _ready() -> void:
	if ServerManager.configuration.is_server:
		MultiplayerGameManager.start_dedicated_server()
	else:
		SceneManager.transition_to.call_deferred("home")
