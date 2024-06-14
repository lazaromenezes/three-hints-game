extends Control

signal timed_up()

@export var hint: String:
	set(value):
		hint = value
		%HintText.text = value

func _ready() -> void:
	$HintTime.start(GameManager.settings.hint_time)

func _process(_delta: float) -> void:
	%Progress.value = $HintTime.time_left / GameManager.settings.hint_time

func _on_timer_timeout() -> void:
	timed_up.emit()
