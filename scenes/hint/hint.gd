extends Control

signal timed_up()

var remaining_time: float:
	get():
		return $HintTime.time_left

@export var hint: String:
	set(value):
		hint = value
		%HintText.text = value

func _ready() -> void:
	$HintTime.start(ConfigurationProvider.settings.hint_time)

func _process(_delta: float) -> void:
	%Progress.value = $HintTime.time_left / ConfigurationProvider.settings.hint_time

func _on_timer_timeout() -> void:
	timed_up.emit()
