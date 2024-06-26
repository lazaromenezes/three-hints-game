extends Control

func _ready():
	if GameManager.session:
		%Points.text = str(GameManager.session.total_points)
		%Time.text = GameManager.session.formatted_time

func _on_main_menu_pressed() -> void:
	SceneManager.transition_to("home")

func _on_new_game_pressed() -> void:
	SceneManager.transition_to("solo")
