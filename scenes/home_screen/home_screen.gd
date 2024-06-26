extends Control

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_solo_game_pressed() -> void:
	SceneManager.transition_to("solo")

func _on_multiplayer_pressed() -> void:
	SceneManager.transition_to("lobby")
