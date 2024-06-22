extends Control

func _ready() -> void:
	SceneManager.load_scenes()

func _process(_delta) -> void:
	var progress = SceneManager.report_status()
	
	%Progress.value = progress
	
	if progress == 1:
		SceneManager.transition_to("home")
